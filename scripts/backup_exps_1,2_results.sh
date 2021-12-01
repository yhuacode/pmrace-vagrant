#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# set environment variables
source /home/vagrant/scripts/env.sh

PM_WORKLOADS_DIR=/home/vagrant/pm-workloads

PCLHT_WORK_DIR=$PM_WORKLOADS_DIR/RECIPE/P-CLHT/build
CLEVEL_WORK_DIR=$PM_WORKLOADS_DIR/Clevel-Hashing/build/tests
CCEH_WORK_DIR=$PM_WORKLOADS_DIR/CCEH/CCEH-PMDK
FF_WORK_DIR=$PM_WORKLOADS_DIR/FAST_FAIR/concurrent_pmdk
MEMCACHED_WORK_DIR=$PM_WORKLOADS_DIR/memcached-pmem

SUFFIX=bak
if [ "$#" -eq 1 ]
then
    SUFFIX=$1
fi

check_workload() {
    if [ $1 == "clevel" ]
    then
        if [ ! -d "$2/output" ]
        then
            echo -e "${RED}$2/output does not exist${NC}"
            exit 1
        fi

        if [ -d "$2/output-$SUFFIX" ]
        then
            echo -e "${GREEN}Overwritting backups of $1 ${NC}"
            rm -rf $2/output-$SUFFIX
        fi
    else
        # usage: check_workload <workload_name> <work_dir>
        if [ ! -d "$2/output" ] || [ ! -d "$2/validate" ]
        then
            echo -e "${RED}$2/output or $2/validate does not exist${NC}"
            exit 1
        fi

        if [ -d "$2/output-$SUFFIX" ] || [ -d "$2/validate-$SUFFIX" ]
        then
            echo -e "${GREEN}Overwritting backups of $1 ${NC}"
            rm -rf $2/output-$SUFFIX $2/validate-$SUFFIX
        fi
    fi
}

backup_workload_result() {
    if [ $1 == "clevel" ]
    then
        cd $2
        mv output output-$SUFFIX
    else
        cd $2
        mv output output-$SUFFIX
        mv validate validate-$SUFFIX
    fi

}

check_workload "pclht" $PCLHT_WORK_DIR
check_workload "clevel" $CLEVEL_WORK_DIR
check_workload "cceh" $CCEH_WORK_DIR
check_workload "fast_fair" $FF_WORK_DIR
check_workload "memcached-pmem" $MEMCACHED_WORK_DIR

echo -e "${GREEN}Make backups with suffix=$SUFFIX ${NC}"
backup_workload_result "pclht" $PCLHT_WORK_DIR
backup_workload_result "clevel" $CLEVEL_WORK_DIR
backup_workload_result "cceh" $CCEH_WORK_DIR
backup_workload_result "fast_fair" $FF_WORK_DIR
backup_workload_result "memcached-pmem" $MEMCACHED_WORK_DIR
