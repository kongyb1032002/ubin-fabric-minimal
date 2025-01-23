#!/bin/bash

start=`date +%s`
echo "1" > cc_version.txt

VERSION=`cat cc_version.txt`

echo "Disabling ping cron job"
./cron_control.sh --disable fabric_ping

# Load files
#!/bin/bash
if [ -e ./config_all.sh ]
then
  source ./config_all.sh
else
  source ~/ubin-fabric-api/scripts/config_all.sh
fi

jq --version > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Please Install 'jq' https://stedolan.github.io/jq/ to execute this script"
    echo
    exit 1
fi

for i in $(seq 0 11); do
  eval name=\$ORG${i}_NAME
  eval host=\$ORG${i}_HOST
  eval config=\$ORG${i}_CONFIG

  echo "Organization: $name"
  echo "Host: $host"
  echo "Config: $config"
  echo "------------------------"
  if [ $(hostname) = $host ]; then
    NETWORK_CONFIG=$config
    ORG_NAME=$name
  fi
  
  NETWORK_CONFIG_FILE=${NETWORK_CONFIG_PATH}/${NETWORK_CONFIG}.json

  ORG_PEER=`jq -r .networkConfig.${ORG_NAME}.orgPeers[0] ${NETWORK_CONFIG_FILE}`
  ORG_USER=`jq -r .networkConfig.${ORG_NAME}.bic ${NETWORK_CONFIG_FILE}`
  ORG_ACCT=${ORG_USER}


  ORG0_BIC=`jq -r .networkConfig.${ORG0_NAME}.bic ${NETWORK_CONFIG_FILE}`
  ORG1_BIC=`jq -r .networkConfig.${ORG1_NAME}.bic ${NETWORK_CONFIG_FILE}`
  ORG2_BIC=`jq -r .networkConfig.${ORG2_NAME}.bic ${NETWORK_CONFIG_FILE}`
  ORG3_BIC=`jq -r .networkConfig.${ORG3_NAME}.bic ${NETWORK_CONFIG_FILE}`
  ORG4_BIC=`jq -r .networkConfig.${ORG4_NAME}.bic ${NETWORK_CONFIG_FILE}`
  ORG5_BIC=`jq -r .networkConfig.${ORG5_NAME}.bic ${NETWORK_CONFIG_FILE}`
  ORG6_BIC=`jq -r .networkConfig.${ORG6_NAME}.bic ${NETWORK_CONFIG_FILE}`
  ORG7_BIC=`jq -r .networkConfig.${ORG7_NAME}.bic ${NETWORK_CONFIG_FILE}`
  ORG8_BIC=`jq -r .networkConfig.${ORG8_NAME}.bic ${NETWORK_CONFIG_FILE}`
  ORG9_BIC=`jq -r .networkConfig.${ORG9_NAME}.bic ${NETWORK_CONFIG_FILE}`
  ORG10_BIC=`jq -r .networkConfig.${ORG10_NAME}.bic ${NETWORK_CONFIG_FILE}`
  ORG11_BIC=`jq -r .networkConfig.${ORG11_NAME}.bic ${NETWORK_CONFIG_FILE}`

  if [ -e ./script_functions_all.sh ]
  then
    source ./script_functions_all.sh
  else
    source ~/ubin-fabric-api/scripts/script_functions_all.sh
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
      InstantiateBilateral bofasg2xcitisgsgchannel
      InstantiateBilateral bofasg2xcsfbsgsxchannel
      InstantiateBilateral bofasg2xdbsssgsgchannel
      InstantiateBilateral bofasg2xhsbcsgsgchannel
      InstantiateBilateral bofasg2xmtbcsgsgchannel
      InstantiateBilateral bofasg2xocbcsgsgchannel
      InstantiateBilateral bofasg2xscblsgsgchannel
      InstantiateBilateral bofasg2xuobvsgsgchannel
      InstantiateBilateral bofasg2xxsimsgsgchannel
      InstantiateBilateral chassgsgcitisgsgchannel
      InstantiateBilateral chassgsgcsfbsgsxchannel
      InstantiateBilateral chassgsgdbsssgsgchannel
      InstantiateBilateral chassgsghsbcsgsgchannel
      InstantiateBilateral chassgsgmtbcsgsgchannel
      InstantiateBilateral chassgsgocbcsgsgchannel
      InstantiateBilateral chassgsgscblsgsgchannel
      InstantiateBilateral chassgsguobvsgsgchannel
      InstantiateBilateral chassgsgxsimsgsgchannel
      InstantiateBilateral citisgsgcsfbsgsxchannel
      InstantiateBilateral citisgsgdbsssgsgchannel
      InstantiateBilateral citisgsghsbcsgsgchannel
      InstantiateBilateral citisgsgmtbcsgsgchannel
      InstantiateBilateral citisgsgocbcsgsgchannel
      InstantiateBilateral citisgsgscblsgsgchannel
      InstantiateBilateral citisgsguobvsgsgchannel
      InstantiateBilateral citisgsgxsimsgsgchannel
      InstantiateBilateral csfbsgsxdbsssgsgchannel
      InstantiateBilateral csfbsgsxhsbcsgsgchannel
      InstantiateBilateral csfbsgsxmtbcsgsgchannel
      InstantiateBilateral csfbsgsxocbcsgsgchannel
      InstantiateBilateral csfbsgsxscblsgsgchannel
      InstantiateBilateral csfbsgsxuobvsgsgchannel
      InstantiateBilateral csfbsgsxxsimsgsgchannel
      InstantiateBilateral dbsssgsghsbcsgsgchannel
      InstantiateBilateral dbsssgsgmtbcsgsgchannel
      InstantiateBilateral dbsssgsgocbcsgsgchannel
      InstantiateBilateral dbsssgsgscblsgsgchannel
      InstantiateBilateral dbsssgsguobvsgsgchannel
      InstantiateBilateral dbsssgsgxsimsgsgchannel
      InstantiateBilateral hsbcsgsgmtbcsgsgchannel
      InstantiateBilateral hsbcsgsgocbcsgsgchannel
      InstantiateBilateral hsbcsgsgscblsgsgchannel
      InstantiateBilateral hsbcsgsguobvsgsgchannel
      InstantiateBilateral hsbcsgsgxsimsgsgchannel
      InstantiateBilateral mtbcsgsgocbcsgsgchannel
      InstantiateBilateral mtbcsgsgscblsgsgchannel
      InstantiateBilateral mtbcsgsguobvsgsgchannel
      InstantiateBilateral mtbcsgsgxsimsgsgchannel
      InstantiateBilateral ocbcsgsgscblsgsgchannel
      InstantiateBilateral ocbcsgsguobvsgsgchannel
      InstantiateBilateral ocbcsgsgxsimsgsgchannel
      InstantiateBilateral scblsgsguobvsgsgchannel
      InstantiateBilateral scblsgsgxsimsgsgchannel
      InstantiateBilateral uobvsgsgxsimsgsgchannel

      InstantiateMultilateral fundingchannel
      InstantiateMultilateral nettingchannel

      sleep 30
      
      InitChannelAccounts bofasg2xchassgsgchannel
      InitChannelAccounts bofasg2xcitisgsgchannel
      InitChannelAccounts bofasg2xcsfbsgsxchannel
      InitChannelAccounts bofasg2xdbsssgsgchannel
      InitChannelAccounts bofasg2xhsbcsgsgchannel
      InitChannelAccounts bofasg2xmtbcsgsgchannel
      InitChannelAccounts bofasg2xocbcsgsgchannel
      InitChannelAccounts bofasg2xscblsgsgchannel
      InitChannelAccounts bofasg2xuobvsgsgchannel
      InitChannelAccounts bofasg2xxsimsgsgchannel
      InitChannelAccounts chassgsgcitisgsgchannel
      InitChannelAccounts chassgsgcsfbsgsxchannel
      InitChannelAccounts chassgsgdbsssgsgchannel
      InitChannelAccounts chassgsghsbcsgsgchannel
      InitChannelAccounts chassgsgmtbcsgsgchannel
      InitChannelAccounts chassgsgocbcsgsgchannel
      InitChannelAccounts chassgsgscblsgsgchannel
      InitChannelAccounts chassgsguobvsgsgchannel
      InitChannelAccounts chassgsgxsimsgsgchannel
      InitChannelAccounts citisgsgcsfbsgsxchannel
      InitChannelAccounts citisgsgdbsssgsgchannel
      InitChannelAccounts citisgsghsbcsgsgchannel
      InitChannelAccounts citisgsgmtbcsgsgchannel
      InitChannelAccounts citisgsgocbcsgsgchannel
      InitChannelAccounts citisgsgscblsgsgchannel
      InitChannelAccounts citisgsguobvsgsgchannel
      InitChannelAccounts citisgsgxsimsgsgchannel
      InitChannelAccounts csfbsgsxdbsssgsgchannel
      InitChannelAccounts csfbsgsxhsbcsgsgchannel
      InitChannelAccounts csfbsgsxmtbcsgsgchannel
      InitChannelAccounts csfbsgsxocbcsgsgchannel
      InitChannelAccounts csfbsgsxscblsgsgchannel
      InitChannelAccounts csfbsgsxuobvsgsgchannel
      InitChannelAccounts csfbsgsxxsimsgsgchannel
      InitChannelAccounts dbsssgsghsbcsgsgchannel
      InitChannelAccounts dbsssgsgmtbcsgsgchannel
      InitChannelAccounts dbsssgsgocbcsgsgchannel
      InitChannelAccounts dbsssgsgscblsgsgchannel
      InitChannelAccounts dbsssgsguobvsgsgchannel
      InitChannelAccounts dbsssgsgxsimsgsgchannel
      InitChannelAccounts hsbcsgsgmtbcsgsgchannel
      InitChannelAccounts hsbcsgsgocbcsgsgchannel
      InitChannelAccounts hsbcsgsgscblsgsgchannel
      InitChannelAccounts hsbcsgsguobvsgsgchannel
      InitChannelAccounts hsbcsgsgxsimsgsgchannel
      InitChannelAccounts mtbcsgsgocbcsgsgchannel
      InitChannelAccounts mtbcsgsgscblsgsgchannel
      InitChannelAccounts mtbcsgsguobvsgsgchannel
      InitChannelAccounts mtbcsgsgxsimsgsgchannel
      InitChannelAccounts ocbcsgsgscblsgsgchannel
      InitChannelAccounts ocbcsgsguobvsgsgchannel
      InitChannelAccounts ocbcsgsgxsimsgsgchannel
      InitChannelAccounts scblsgsguobvsgsgchannel
      InitChannelAccounts scblsgsgxsimsgsgchannel
      InitChannelAccounts uobvsgsgxsimsgsgchannel
  fi


  echo "Enabling ping cron job"
  ./cron_control.sh --enable fabric_ping


done

end=`date +%s`
runtime=$((end-start))
echo "Initialization completed as of $(date)"
echo "Script Execution Time: ${runtime}"
