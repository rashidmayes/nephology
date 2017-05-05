#!/bin/bash

NAME=$1
ID=$1
OUTPUT_FILE=$2
OUTPUT_TYPE=text/plain
DESCRIPTION="This test uses the JMH microbenchmark framework to evaluate system performance."
STATUS="OK"
STATUS_CODE=0
SCORE=1
SCORE_EXPLANATION="The score represents the average number of operations per second performed in the test."
START_TIME=$(expr `date +%s` \* 1000)


#################################################################
#
# Test
#
#################################################################
function test {
pushd .
mkdir /tmp/jmh
cd /tmp/jmh
pwd

mvn archetype:generate \
	-DinteractiveMode=false \
    -DarchetypeGroupId=org.openjdk.jmh \
    -DarchetypeArtifactId=jmh-java-benchmark-archetype \
    -DgroupId=org.sample \
    -DartifactId=jmhtools \
    -Dversion=1.0
          
cd jmhtools
mvn clean install

raw=$(java -jar target/benchmarks.jar -v EXTRA)
SCORE=$(echo "$raw" | tail -1 | awk '{ print $4 }')
OUTPUT=$(base64 -w0<<<"$raw")
OUTPUT_LEN=${#raw}

popd
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
