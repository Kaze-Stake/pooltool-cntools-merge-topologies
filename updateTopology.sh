#!/bin/bash
# This script is based of the following guide:
# https://www.coincashew.com/coins/overview-ada/guide-how-to-build-a-haskell-stakepool-node

# Remove connections to your own nodes (and IOHK) from one of your topologies
# either on https://pooltool.io through the UI or by removing everything in the
# string behind &customPeers= in the file relay-topology_pull.sh

# You might also want to avoid adding relays from the CNTools topology to your
# PoolTool buddies list

# You also need to replace mentions of mainnet-topology.json in get_buddies.sh
# and relay-topology_pull.sh with pt-topology.json and cnt-topology.json

# cardano-node home folder
DIRECTORY=$NODE_HOME
# Name of tmux session running cardano-node
SESSION="relay1"

# Pull PoolTool and CNTools topologies
bash ${DIRECTORY}/get_buddies.sh
PT_TOPOLOGY=${DIRECTORY}/pt-topology.json
bash ${DIRECTORY}/relay-topology_pull.sh
CNT_TOPOLOGY=${DIRECTORY}/cnt-topology.json

# Remove the first two lines from PoolTool topology
TMP=$(mktemp)
tail -n +3 $PT_TOPOLOGY > $TMP
cat $TMP > $PT_TOPOLOGY
rm -f $TMP

# Remove the last line from CNTools topology
sed -i '$ d' $CNT_TOPOLOGY

# Put file contents into variables
PT_FILE_CONTENT=$(<$PT_TOPOLOGY)
CNT_FILE_CONTENT=$(<$CNT_TOPOLOGY)

# Prettify and put the result into mainnet-topology.json
TMP=$(mktemp)
echo $CNT_FILE_CONTENT > $TMP
sed -i '$ s/$/,/' $TMP
echo $PT_FILE_CONTENT >> $TMP
jq . $TMP > ${DIRECTORY}/mainnet-topology.json

# Delete temporary files
rm -f $TMP
rm -f ${DIRECTORY}/pt-topology.json
rm -f ${DIRECTORY}/cnt-topology.json
