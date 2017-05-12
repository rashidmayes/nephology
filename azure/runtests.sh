#!/bin/bash
rm -rf nephology
git clone https://github.com/rashidmayes/nephology.git
cd nephology/azure
./main.sh $*
#shutdown -h now &