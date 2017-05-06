#!/bin/bash
#set -x

SYSTEM_ENV=`env`
TOKEN=$3
CLOUD=$1
INSTANCE_TYPE=$2

URL_PATH="api/v1/instances/$CLOUD/$INSTANCE_TYPE/runs/io/create"
HOST=cloudvoyance.io
SERVICE_URL=http://$HOST/$URL_PATH


COMMAND_DIR=commands
OUTPUT_DIR=/tmp/`basename $0 .sh`/$$
mkdir -p $OUTPUT_DIR


#################################################################
#
# HEADER INFO
#
#################################################################
function createPreamble {

#CPU_COUNT=`lscpu | awk '/^CPU\(s\)/ { print $2; }'`
CPU_COUNT=`nproc`
CPU_SPEED=`lscpu | awk  '/^CPU MHz/ { print $3; }'`
MEMORY=`free -b | awk '/Mem/ { print $2 }'`
DRIVE_DETAILS=(`lsblk -bl -o SIZE,TYPE | awk '/disk/ {sum += $1; count += 1;} END {print sum " " count}'`)
    
cat<<EOF > $OUTPUT_DIR/preamble.json
{
      "cpuCount" : $CPU_COUNT,
      "memory" : $MEMORY,
      "driveCount" : ${DRIVE_DETAILS[1]},
      "driveSize" : ${DRIVE_DETAILS[0]},
      "clockSpeed" : $CPU_SPEED
}
EOF

}


#################################################################
#
# RUN TESTS
#
#################################################################
function runTests {
    ls $COMMAND_DIR | while read script
    do
        command_name=`basename $script .sh`
        output_file=$OUTPUT_DIR/$command_name.out
        echo $command_name
        $COMMAND_DIR/$script $command_name $output_file 
    done
}


createPreamble
runTests


TESTS=`ls $OUTPUT_DIR/*out | while read f; do printf " -F test=@$f"; done`

echo curl -vS --header "token: $TOKEN" -F "t=@$OUTPUT_DIR/preamble.json" $TESTS $SERVICE_URL
curl -vS --header "token: $TOKEN" -F "t=@$OUTPUT_DIR/preamble.json" $TESTS $SERVICE_URL