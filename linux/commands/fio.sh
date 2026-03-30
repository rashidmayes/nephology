#!/bin/bash

NAME=$1
ID=$1
OUTPUT_FILE=$2
OUTPUT_TYPE=text/plain
DESCRIPTION="This test uses the Flexible IO Tester to determine the number of drive IOPS. Additional tests are run usng ioping. The OS drive is not evaluated during this test."
STATUS="OK"
STATUS_CODE=0
SCORE=1
SCORE_EXPLANATION="The score represents the sum total of all iops for all devices."
START_TIME=$(expr `date +%s` \* 1000)
ROOT_VOLUME=$(lsblk -no pkname `findmnt / -no source`)

#################################################################
#
# Test
#
#################################################################
function inspect {

lsblk -o NAME,TYPE | grep disk | grep -v "^sda\|^xvda\|^$ROOT_VOLUME" | while read name type
do 
    echo ioping -s 131072 -c 10 /dev/$name
    sudo /usr/local/bin/ioping -s 131072 -c 10 /dev/$name
    echo
    
    
    echo ioping -s 131072 -c 10 -D /dev/$name O_DIRECT
    sudo /usr/local/bin/ioping -s 131072 -c 10 -D /dev/$name
    echo

    echo fio --filename=/dev/$name --name=randwrite --ioengine=libaio --iodepth=16 --rw=randrw --bs=4k --direct=0 --numjobs=1 --runtime=60  --rwmixwrite=50 --norandommap --group_reporting
    
    sudo fio --filename=/dev/$name --name=randwrite --ioengine=libaio --iodepth=16 --rw=randrw --bs=4k --direct=0 --numjobs=1 --runtime=60  --rwmixwrite=50 --norandommap --group_reporting
    echo
    
    echo fio --filename=/dev/$name --name=randwrite --ioengine=libaio --iodepth=16 --rw=randrw --bs=4k --direct=1 --numjobs=1 --runtime=60  --rwmixwrite=50 --norandommap --group_reporting
    
    sudo fio --filename=/dev/$name --name=randwrite --ioengine=libaio --iodepth=16 --rw=randrw --bs=4k --direct=1 --numjobs=1 --runtime=60  --rwmixwrite=50  --norandommap --group_reporting
    echo
done
}

function test {
raw=$(inspect)
OUTPUT=$(base64 -w0<<<"$raw")
#SCORE=$(awk '/^  write:/ { split($4,iops,"="); sum+=strtonum(iops[2]); } END { print sum/2 }'<<<"$raw")
SCORE=$(awk '/^  write:/ { split($2,iops,"="); print iops[2]  }'<<<"$raw" | tr -d ',' | tr '[:lower:]' '[:upper:]' | numfmt --from=auto | awk '{ sum+=strtonum($1); } END { print sum/2 }')
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
