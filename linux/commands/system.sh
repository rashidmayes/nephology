#!/bin/bash

NAME=$1
ID=$1
OUTPUT_FILE=$2
OUTPUT_TYPE=text/plain
DESCRIPTION="This test uses various system tools to display information about the host environment."
STATUS="OK"
STATUS_CODE=0
SCORE=0
SCORE_EXPLANATION="A value of 1 is given to any successful execution."
START_TIME=$(expr `date +%s` \* 1000)


#################################################################
#
# Test
#
#################################################################
function inspect {
echo uname
uname -a
echo 

echo *release
ls /etc/*release | while read f
do
    echo $f
    cat $f
    echo
done


echo chkconfig
chkconfig
echo

echo service --status-all
sudo service --status-all
echo

echo sudo netstat -lpn | grep -v "^unix"
sudo netstat -lpn | grep -v "^unix"
echo

echo  df -h
df -h
echo

echo  sudo lshw
sudo lshw
echo

#wget -q -O - http://169.254.169.254/latest/dynamic/instance-identity/document
}


function test {
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