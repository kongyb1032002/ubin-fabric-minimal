'use strict';
var path = require('path');
var fs = require('fs');
var util = require('util');
var config = require('../config.json');
var helper = require('./helper.js');
var logger = helper.getLogger('upgrade-chaincode');
var ORGS = helper.ORGS;
var tx_id = null;
var eh = null;

var upgradeChaincode = function (peersUrls, channelName, chaincodeName, chaincodeVersion, functionName, args, username, org, endorsementPolicy) {
	logger.debug('\n============ Upgrade chaincode on organization ' + org +
		' ============\n');

	var channel = helper.getChannelForOrg(org + ':' + channelName);
	var client = helper.getClientForOrg(org);
	var targets = helper.newPeers(peersUrls);

	return helper.getOrgAdmin(org).then((user) => {
		// read the config block from the orderer for the channel and initialize the verify MSPs based on the participating organizations
		return channel.initialize();
	}, (err) => {
		logger.error('Failed to enroll user \'' + username + '\'. ' + err);
		throw new Error('Failed to enroll user \'' + username + '\'. ' + err);
	}).then((success) => {
		tx_id = client.newTransactionID();

		// send proposal to endorser
		if (chaincodeName === "bilateralchannel_cc") {
			var bilateralOrg = helper.getBilateralOrgName(org, channelName);
			var request = {
				targets: targets,
				chaincodeId: chaincodeName,
				chaincodeVersion: chaincodeVersion,
				fcn: functionName,
				args: args,
				txId: tx_id,
				'endorsement-policy': {
					identities: [
						{ role: { name: 'member', mspId: ORGS[org].mspid } },
						{ role: { name: 'member', mspId: ORGS[bilateralOrg].mspid } }
					],
					policy: {
						'2-of': [{ 'signed-by': 0 }, { 'signed-by': 1 }]
					}
				}
			};
		} else if (chaincodeName === "fundingchannel_cc") {
			var request = {
				targets: targets,
				chaincodeId: chaincodeName,
				chaincodeVersion: chaincodeVersion,
				fcn: functionName,
				args: args,
				txId: tx_id,
				'endorsement-policy': {
					identities: [
						{ role: { name: 'member', mspId: ORGS['org0'].mspid } },
						{ role: { name: 'member', mspId: ORGS['org1'].mspid } },
						{ role: { name: 'member', mspId: ORGS['org2'].mspid } },
					],
					policy: {
						'2-of': [
							{ 'signed-by': 0 },
							{ 'signed-by': 1 },
							{ 'signed-by': 2 }
						]
					}
				}
			};
		} else if (chaincodeName === "nettingchannel_cc") {
			var request = {
				targets: targets,
				chaincodeId: chaincodeName,
				chaincodeVersion: chaincodeVersion,
				fcn: functionName,
				args: args,
				txId: tx_id,
				'endorsement-policy': {
					identities: [
						{ role: { name: 'member', mspId: ORGS['org0'].mspid } },
						{ role: { name: 'member', mspId: ORGS['org1'].mspid } },
						{ role: { name: 'member', mspId: ORGS['org2'].mspid } }
					],
					policy: {
						'12-of': [
							{ 'signed-by': 0 },
							{ 'signed-by': 1 },
							{ 'signed-by': 2 },
						]
					}
				}
			};
		} else {
			logger.error('Chaincode name not recognized');
		}

		logger.info("Proposal Request : " + request.toString());
		return channel.sendUpgradeProposal(request, 120000);
	}, (err) => {
		logger.error('Failed to initialize the channel');
		throw new Error('Failed to initialize the channel');
	}).then((results) => {
		logger.info("Proposal Results : " + results);
		var proposalResponses = results[0];
		var proposal = results[1];
		var all_good = true;
		for (var i in proposalResponses) {
			let one_good = false;
			if (proposalResponses && proposalResponses[0].response &&
				proposalResponses[0].response.status === 200) {
				one_good = true;
				logger.info('Upgrade proposal was good');
			} else {
				logger.error('Upgrade proposal was bad ' + proposalResponses[i]);
			}
			all_good = all_good & one_good;
		}
		if (all_good) {
			logger.info(util.format(
				'Successfully sent Proposal and received ProposalResponse: Status - %s, message - "%s", metadata - "%s", endorsement signature: %s',
				proposalResponses[0].response.status, proposalResponses[0].response.message,
				proposalResponses[0].response.payload, proposalResponses[0].endorsement
				.signature));
			var request = {
				proposalResponses: proposalResponses,
				proposal: proposal
			};
			// set the transaction listener and set a timeout of 30sec
			// if the transaction did not get committed within the timeout period,
			// fail the test
			var deployId = tx_id.getTransactionID();

			eh = client.newEventHub();
			let data = fs.readFileSync(path.join(__dirname, ORGS[org]['peer0'][
				'tls_cacerts'
			]));
			eh.setPeerAddr(ORGS[org]['peer0']['events'], {
				pem: Buffer.from(data).toString(),
				'ssl-target-name-override': ORGS[org]['peer0']['server-hostname']
			});
			eh.connect();

			let txPromise = new Promise((resolve, reject) => {
				let handle = setTimeout(() => {
					eh.disconnect();
					reject();
				}, 30000);

				eh.registerTxEvent(deployId, (tx, code) => {
					logger.info(
						'The chaincode upgrade transaction has been committed on peer ' +
						eh._ep._endpoint.addr);
					clearTimeout(handle);
					eh.unregisterTxEvent(deployId);
					eh.disconnect();

					if (code !== 'VALID') {
						logger.error('The chaincode upgrade transaction was invalid, code = ' + code);
						reject();
					} else {
						logger.info('The chaincode upgrade transaction was valid.');
						resolve();
					}
				});
			});

			var sendPromise = channel.sendTransaction(request);
			return Promise.all([sendPromise].concat([txPromise])).then((results) => {
				logger.debug('Event promise all complete and testing complete');
				return results[0]; // the first returned value is from the 'sendPromise' which is from the 'sendTransaction()' call
			}).catch((err) => {
				logger.error(
					util.format('Failed to send upgrade transaction and get notifications within the timeout period. %s', err)
				);
				return 'Failed to send upgrade transaction and get notifications within the timeout period.';
			});
		} else {
			logger.error(
				'Failed to send upgrade Proposal or receive valid response. Response null or status is not 200. exiting...'
			);
			return 'Failed to send upgrade Proposal or receive valid response. Response null or status is not 200. exiting...';
		}
	}, (err) => {
		logger.error('Failed to send upgrade proposal due to error: ' + err.stack ?
			err.stack : err);
		return 'Failed to send upgrade proposal due to error: ' + err.stack ?
			err.stack : err;
	}).then((response) => {
		if (response.status === 'SUCCESS') {
			logger.info('Successfully sent transaction to the orderer.');
			return 'Chaincode Upgrade is SUCCESS';
		} else {
			logger.error('Failed to order the transaction. Error code: ' + response.status);
			return 'Failed to order the transaction. Error code: ' + response.status;
		}
	}, (err) => {
		logger.error('Failed to send upgrade due to error: ' + err.stack ? err
			.stack : err);
		return 'Failed to send upgrade due to error: ' + err.stack ? err.stack :
			err;
	});
};
exports.upgradeChaincode = upgradeChaincode;
