#!/bin/bash
#set -x

sudo yum -y install dmidecode
sudo yum -y install ioping
sudo yum -y install sysbench
sudo yum -y install bind-utils
sudo yum -y install traceroute
sudo yum -y install nmap
sudo yum -y install fio
sudo yum -y install java-1.8.0-openjdk-devel-debug.x86_64
sudo yum -y install lshw
sudo yum -y install pciutils

sudo wget http://repos.fedorapeople.org/repos/dchen/apache-maven/epel-apache-maven.repo -O /etc/yum.repos.d/epel-apache-maven.repo
sudo sed -i s/\$releasever/6/g /etc/yum.repos.d/epel-apache-maven.repo
sudo yum -y install apache-maven

wget https://www.percona.com/redir/downloads/percona-release/redhat/latest/percona-release-0.1-4.noarch.rpm
sudo rpm -Uvh percona-release-0.1-4.noarch.rpm
sudo yum -y install sysbench

sudo pip install --upgrade speedtest-cli