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

      InstantiateMultilateral fundingchannel
      InstantiateMultilateral nettingchannel

      sleep 30
      
      InitChannelAccounts bofasg2xchassgsgchannel
  fi


  echo "Enabling ping cron job"
  ./cron_control.sh --enable fabric_ping


done

end=`date +%s`
runtime=$((end-start))
echo "Initialization completed as of $(date)"
echo "Script Execution Time: ${runtime}"
