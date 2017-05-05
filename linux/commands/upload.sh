#!/bin/bash

NAME=$1
ID=$1
OUTPUT_FILE=$2
OUTPUT_TYPE=text/json
DESCRIPTION="This test uses speedtest-cli (speedtest.net) to measure the network upload speed in bits per second."
STATUS="OK"
STATUS_CODE=0
SCORE=0
SCORE_EXPLANATION="The score represents the bits per second rate."
START_TIME=$(expr `date +%s` \* 1000)


#################################################################
#
# Test
#
#################################################################
function test {
raw=$(/usr/local/bin/speedtest --json --no-download | awk 'NR > 1 { print $0 }' | python -m json.tool)
SCORE=$(python -c 'import json,sys; print(json.loads(sys.stdin.read())["upload"])'<<<"$raw")
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
