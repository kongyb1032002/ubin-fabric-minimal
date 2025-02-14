#!/usr/bin/env bash

REGULATOR_NAME=masgsgsg
MULTILATERAL_CHANNELS=( 'fundingchannel' 'nettingchannel' )
CHANNEL_SCRIPT_DIR=/etc/hyperledger/configtx

ALL_CHANNEL_TXS=( $(ls -q channel-artifacts/*-channel.tx | xargs -n 1 basename) )

# Danh sách các peer
PEER_ORGS=("masgsgsg" "bofasg2x" "chassgsg")

# Lặp qua tất cả các peer
for bank_name in "${PEER_ORGS[@]}"; do
    container=$(docker ps | grep "_peer0-${bank_name,,}")  # Tìm container với tên phù hợp (chuyển tên thành chữ thường)

    if [[ ${container} =~ ^([0-9a-f]+)\ .*peer0-([a-z,0-9]*)\. ]]; then
        container_id="${BASH_REMATCH[1]}"
        peer_name="${BASH_REMATCH[2]}"
        echo
        echo "---------- Peer Configuration ----------"
        echo " Bank Name    : ${peer_name}"
        echo " Container ID : ${container_id}"
        echo "----------------------------------------"
        echo

        # Tạo Channels nếu peer là Regulator
        if [[ ${peer_name} = ${REGULATOR_NAME} ]]; then
            echo "Regulator peer found. Creating channels..."
            docker exec ${container_id} bash ${CHANNEL_SCRIPT_DIR}/create-channel.sh
            echo
        else
            echo "Regulator peer not found. Skipping channel creation..."
        fi

        # Tham gia Channels
        filter_channels() {
            for channel_tx in "${ALL_CHANNEL_TXS[@]}"; do
                [[ ${channel_tx} == *$1* ]] && res+=("${channel_tx%-channel.tx}channel")
            done
            echo "${res[@]}"
        }

        channels=""
        if [ ${peer_name} = ${REGULATOR_NAME} ]; then
            channels=( $(filter_channels) )
        else
            channels=( $(filter_channels ${peer_name}) "fundingchannel" "nettingchannel" )
        fi

        docker exec $container_id bash ${CHANNEL_SCRIPT_DIR}/join-channel.sh ${peer_name} ${channels[@]}
    fi
done
