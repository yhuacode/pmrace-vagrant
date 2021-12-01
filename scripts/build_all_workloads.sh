#!/bin/bash

echo -e "${GREEN}Build pm-workloads${NC}"
git clone https://github.com/yhuacode/pm-workloads.git /home/vagrant/pm-workloads/
cd /home/vagrant/pm-workloads
git submodule init && git submodule update --progress

SCRIPT_PATH=/home/vagrant/scripts/build_workload.sh

$SCRIPT_PATH pclht
$SCRIPT_PATH memcached
$SCRIPT_PATH cceh
$SCRIPT_PATH fast_fair
$SCRIPT_PATH clevel
