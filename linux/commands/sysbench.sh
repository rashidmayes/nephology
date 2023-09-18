#!/bin/bash

NAME=$1
ID=$1
OUTPUT_FILE=$2
OUTPUT_TYPE=text/plain
DESCRIPTION="This test uses sysbench to run a CPU performance test. A total of 8 threads are used to calculate prime numbers for a duration of 60 seconds."
STATUS="OK"
STATUS_CODE=0
SCORE=1
SCORE_EXPLANATION="The score represents the number of operations performed per second."
START_TIME=$(expr `date +%s` \* 1000)


#################################################################
#
# Test
#
#################################################################
function test {
raw=$(sysbench cpu --threads=8 --histogram=on --time=60  --cpu-max-prime=20000 run)
SCORE=$(awk '/\(eps\):/ { rate=$3; } END { print rate }'<<<"$raw")
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
