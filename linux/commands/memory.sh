#!/bin/bash

NAME=$1
ID=$1
OUTPUT_FILE=$2
OUTPUT_TYPE=text/plain
DESCRIPTION="This test uses the information in the /proc/meminfo virtual file to display information about the system memory."
STATUS="OK"
STATUS_CODE=0
SCORE=0
SCORE_EXPLANATION="The score is determined by the number of GB memory available to the system as measured with 1 GB = 10^9 bytes."
START_TIME=$(expr `date +%s` \* 1000)


#################################################################
#
# Test
#
#################################################################
function test {

SCORE=`free -b | awk '/Mem/ { print $2/(1000*1000*1000) }'`

raw=$(cat /proc/meminfo)
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