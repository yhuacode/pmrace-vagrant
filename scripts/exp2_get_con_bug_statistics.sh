#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# set environment variables
source /home/vagrant/scripts/env.sh

PYTHON_SCRIPT_PATH=$PMRACE_DIR/scripts/gen_statistics.py
PM_WORKLOADS_DIR=/home/vagrant/pm-workloads

PCLHT_WORK_DIR=$PM_WORKLOADS_DIR/RECIPE/P-CLHT/build
CLEVEL_WORK_DIR=$PM_WORKLOADS_DIR/Clevel-Hashing/build/tests
CCEH_WORK_DIR=$PM_WORKLOADS_DIR/CCEH/CCEH-PMDK
FF_WORK_DIR=$PM_WORKLOADS_DIR/FAST_FAIR/concurrent_pmdk
MEMCACHED_WORK_DIR=$PM_WORKLOADS_DIR/memcached-pmem

PCLHT_BUGS="Nan"
CLEVEL_BUGS="Nan"
CCEH_BUGS="Nan"
FF_BUGS="Nan"
MEMCACHED_BUGS="Nan"

OUTPUT_FOLDER=output
VALIDATE_FOLDER=validate
if [ "$#" -eq 1 ]
then
    OUTPUT_FOLDER=$OUTPUT_FOLDER-$1
    VALIDATE_FOLDER=$VALIDATE_FOLDER-$1
fi

if [ -d $PCLHT_WORK_DIR/$VALIDATE_FOLDER ]
then
    cd $PCLHT_WORK_DIR
    echo -e "${GREEN}Entering $(pwd) ${NC}"
    PCLHT_BUGS=$(python3 $PYTHON_SCRIPT_PATH $OUTPUT_FOLDER $VALIDATE_FOLDER | tail -n 1)
else
    echo -e "${RED}$PCLHT_WORK_DIR/$VALIDATE_FOLDER does not exist!${NC}"
    echo -e "${RED}Post-failure validation for P-CLHT is required before counting!${NC}"
    exit 1
fi

if [ -d $CLEVEL_WORK_DIR/$OUTPUT_FOLDER ]
then
    cd $CLEVEL_WORK_DIR
    echo -e "${GREEN}Entering $(pwd) ${NC}"
    CLEVEL_BUGS=$(python3 $PYTHON_SCRIPT_PATH $OUTPUT_FOLDER | tail -n 1)
else
    echo -e "${RED}$CLEVEL_WORK_DIR/$OUTPUT_FOLDER does not exist!${NC}"
    echo -e "${RED}Bug detection for Clevel Hashing is required before counting!${NC}"
    exit 1
fi

if [ -d $CCEH_WORK_DIR/$VALIDATE_FOLDER ]
then
    cd $CCEH_WORK_DIR
    echo -e "${GREEN}Entering $(pwd) ${NC}"
    CCEH_BUGS=$(python3 $PYTHON_SCRIPT_PATH $OUTPUT_FOLDER $VALIDATE_FOLDER | tail -n 1)
else
    echo -e "${RED}$CCEH_WORK_DIR/$VALIDATE_FOLDER does not exist!${NC}"
    echo -e "${RED}Post-failure validation for CCEH is required before counting!${NC}"
    exit 1
fi

if [ -d $FF_WORK_DIR/$VALIDATE_FOLDER ]
then
    cd $FF_WORK_DIR
    echo -e "${GREEN}Entering $(pwd) ${NC}"
    FF_BUGS=$(python3 $PYTHON_SCRIPT_PATH $OUTPUT_FOLDER $VALIDATE_FOLDER | tail -n 1)
else
    echo -e "${RED}$FF_WORK_DIR/$VALIDATE_FOLDER does not exist!${NC}"
    echo -e "${RED}Post-failure validation for FAST-FAIR is required before counting!${NC}"
    exit 1
fi

if [ -d $MEMCACHED_WORK_DIR/$VALIDATE_FOLDER ]
then
    cd $MEMCACHED_WORK_DIR
    echo -e "${GREEN}Entering $(pwd) ${NC}"
    MEMCACHED_BUGS=$(python3 $PYTHON_SCRIPT_PATH $OUTPUT_FOLDER $VALIDATE_FOLDER | tail -n 1)
else
    echo -e "${RED}$MEMCACHED_WORK_DIR/$VALIDATE_FOLDER does not exist!${NC}"
    echo -e "${RED}Post-failure validation for memcached-pmem is required before counting!${NC}"
    exit 1
fi

echo -e "\n${GREEN}The statistics of PM concurrency bug detection ${NC}\n"
echo -e "\t\t         Inconsistencies   || False Positives || "
echo -e "\t\t  Inter-C* | Inter |  Sync || Inter |  Sync   ||   Bug"
echo -e "        P-CLHT: $PCLHT_BUGS"
echo -e "Clevel Hashing: $CLEVEL_BUGS"
echo -e "          CCEH: $CCEH_BUGS"
echo -e "     FAST-FAIR: $FF_BUGS"
echo -e "memcached-pmem: $MEMCACHED_BUGS \n"
echo -e "Note that Inter-C* indicates PM inter-thread inconsistency candidates.\n"
