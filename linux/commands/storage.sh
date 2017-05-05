#!/bin/bash

NAME=$1
ID=$1
OUTPUT_FILE=$2
OUTPUT_TYPE=text/plain
DESCRIPTION="This test displays drive details using fdisk and lsblk.  Only devices with TYPE of disk are included in the total number of bytes calculation."
STATUS="OK"
STATUS_CODE=0
SCORE=0
SCORE_EXPLANATION="The score represents the total number of bytes across all disk devices."
START_TIME=$(expr `date +%s` \* 1000)


#################################################################
#
# Test
#
#################################################################
function inspect {
echo fdisk -l
sudo fdisk -l
echo
echo lsblk -t
lsblk -t
}

function test {
SCORE=(`lsblk -bl -o SIZE,TYPE | awk '/disk/ {sum += $1; count += 1;} END {print sum}'`)
raw=`inspect`
OUTPUT=$(base64 -w0<<<"$raw")
OUTPUT_LEN=${#raw}
}


#################################################################
#
# Save
#
#################################################################
function save {

cat<<EOF | tee $OUTPUT_FILE
{
  "name" : "$NAME",
  "description" : "$DESCRIPTION",
  "id" : "$ID",
  "startTime" : $START_TIME,
  "outputType" : "$OUTPUT_TYPE",
  "endTime" : $(expr `date +%s` \* 1000),
  "statusCode" : $STATUS_CODE,
  "status" : "$STATUS",
  "score" : $SCORE,
  "scoreExplanation" : "$SCORE_EXPLANATION",
  "output" : "$OUTPUT",
  "outputLength" : $OUTPUT_LEN
}  
EOF

}


test
save