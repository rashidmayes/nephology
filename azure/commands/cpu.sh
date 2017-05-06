#!/bin/bash
#set -x

NAME=$1
ID=$1
OUTPUT_FILE=$2
OUTPUT_TYPE=text/plain
DESCRIPTION="This test uses the /proc/cpuinfo virtual file to display the processors used by the OS."
STATUS="OK"
STATUS_CODE=0
SCORE=0
SCORE_EXPLANATION="The score respresents the totoal number of cores available to the OS. Higher values are better."
START_TIME=$(expr `date +%s` \* 1000)


#################################################################
#
# Test
#
#################################################################
function test {
SCORE=(`cat /proc/cpuinfo | awk '/^cpu cores/ {sum += $4} END {print sum}'`)
raw=$(cat /proc/cpuinfo)
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