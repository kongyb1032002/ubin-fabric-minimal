#!/bin/bash

start=`date +%s`
echo "1" > cc_version.txt

VERSION=`cat cc_version.txt`

echo "Disabling ping cron job"
./cron_control.sh --disable fabric_ping

# Load files
if [ -e ./script_functions.sh ]
then
    echo "script_functions.sh found in current folder"
    . ./script_functions.sh
else
    echo "script_functions.sh not found in current folder. Execute via direct path..."
    . ~/ubin-fabric-api/scripts/script_functions.sh
fi

mkdir -p ../logs
RestartNodeJS

echo
echo "---------------- VM CONFIGURATIONS ----------------"
echo " NAME: ${ORG_NAME}"
echo " USER: ${ORG_USER}"
echo " ACCT: ${ORG_ACCT}"
echo " PEER: ${ORG_PEER}"
echo " CONFIG FILE: ${NETWORK_CONFIG_FILE}"
echo "---------------------------------------------------"
echo

Enroll
Install bilateralchannel
Install fundingchannel
Install nettingchannel

if [ ${ORG_NAME} = ${REGULATOR_ORG} ]
then
    sleep 20
    InstantiateBilateral bofasg2xchassgsgchannel

    InstantiateMultilateral fundingchannel
    InstantiateMultilateral nettingchannel

    sleep 30
    
    InitChannelAccounts bofasg2xchassgsgchannel
fi


echo "Enabling ping cron job"
./cron_control.sh --enable fabric_ping

end=`date +%s`
runtime=$((end-start))
echo "Initialization completed as of $(date)"
echo "Script Execution Time: ${runtime}"
