#!/bin/bash

NAME=$1
ID=$1
OUTPUT_FILE=$2
OUTPUT_TYPE=text/plain
DESCRIPTION="This test uses various system utilities to display the characteristics of the network."
STATUS="OK"
STATUS_CODE=0
SCORE=$(cat /sys/class/net/*/speed 2>/dev/null | awk '{sum += $1} END {print sum+0}')
SCORE_EXPLANATION="The score represents the sum total number of Mbps provided by the network interfaces. The score will be 0 for virtual network interfaces"
START_TIME=$(expr `date +%s` \* 1000)
#netstat -i | grep -v ^lo | tail -n +3 | cut -d' ' -f1


#################################################################
#
# Test
#
#################################################################
function inspect {

echo netstat -i
netstat -i
echo

echo ifconfig -a
sudo ifconfig -a
echo

echo ip ntable
ip ntable
echo

echo arp -a
arp -a
echo

echo netstat -s
netstat -s
echo

echo nmap 127.0.0.1
nmap 127.0.0.1
echo

echo ping -c 10 amazon.com
ping -c 10 amazon.com
echo

echo ping -c 10 google.com
ping -c 10 google.com
echo

echo traceroute google.com
traceroute google.com
echo

echo traceroute amazon.com
traceroute amazon.com
}


function test {
raw=$(inspect)
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