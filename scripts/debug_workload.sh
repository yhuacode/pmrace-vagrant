#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# set environment variables
source /home/vagrant/scripts/env.sh

SEED_SCALE=sample
if [ "$#" -eq 0 ]
then
    echo -e "${RED}Usage: $0 WORKLOAD [SCALE]"
    echo -e "\tSCALE: optioal parameter for seed number. Valid values are 'sample' (default) or 'full' ${NC}"
    exit 1
elif [ "$#" -ge 2 ] && [ "$2" == "full" ]
then
    SEED_SCALE=full
fi

PM_WORKLOADS_DIR=/home/vagrant/pm-workloads
SEED_DIR=/home/vagrant/seeds/$SEED_SCALE

echo -e "${GREEN}Debugging $1 using seeds from $SEED_DIR ${NC}"

# ensure the libPMRaceHook.so is the pre-failure version
cd $PMRACE_DIR/instrument
if [[ -e libPMRaceHook.so ]] && [[ -e libPMRaceHook-PreFailure.so ]] && [[ $(sha1sum libPMRaceHook.so | cut -d " " -f 1) == $(sha1sum libPMRaceHook-PreFailure.so | cut -d " " -f 1) ]]
then
    echo -e "libPMRaceHook.so is the pre-failure version."
else
    echo -e "${GREEN}Change libPMRaceHook.so to the pre-failure version. ${NC}"
    rm -f libPMRaceHook.so
    make
fi

if [ "$1" == "pclht" ]
then
    # RECIPE
    cd $PM_WORKLOADS_DIR/RECIPE/P-CLHT/build
    $PMRACE_DIR/scripts/clear.sh                   # clear the results of previous tests
    python3 $PMRACE_DIR/scripts/fuzz.py -e p-clht -d ./CMakeFiles/driver.dir -p $PMRACE_DIR/deps/pmdk -s $SEED_DIR/pclht
elif [ "$1" == "memcached" ]
then
    # memcached-pmem

    # kill zombie processes of memcached
    killall -9 memcached 2>/dev/null

    cd $PM_WORKLOADS_DIR/memcached-pmem
    $PMRACE_DIR/scripts/clear.sh                   # clear the results of previous tests
    python3 $PMRACE_DIR/scripts/fuzz.py -e memcached -d ./ -p $PMRACE_DIR/deps/pmdk -s $SEED_DIR/memcached

    # kill zombie processes of memcached
    killall -9 memcached 2>/dev/null
elif [ "$1" == "cceh" ]
then
    # CCEH
    cd $PM_WORKLOADS_DIR/CCEH/CCEH-PMDK
    $PMRACE_DIR/scripts/clear.sh                   # clear the results of previous tests
    python3 $PMRACE_DIR/scripts/fuzz.py -e cceh -d ./ -p $PMRACE_DIR/deps/pmdk -s $SEED_DIR/cceh
elif [ "$1" == "fast_fair" ]
then
    # FAST_FAIR
    cd $PM_WORKLOADS_DIR/FAST_FAIR/concurrent_pmdk
    $PMRACE_DIR/scripts/clear.sh                   # clear the results of previous tests
    python3 $PMRACE_DIR/scripts/fuzz.py -e fast-fair -d ./ -p $PMRACE_DIR/deps/pmdk -s $SEED_DIR/ff
elif [ "$1" == "clevel" ]
then
    # Clevel-Hashing
    cd $PM_WORKLOADS_DIR/Clevel-Hashing/build/tests
    $PMRACE_DIR/scripts/clear.sh                   # clear the results of previous tests
    python3 $PMRACE_DIR/scripts/fuzz.py -e clevel -d ./CMakeFiles/clevel_hash_ycsb.dir -p $PMRACE_DIR/deps/pmdk -s $SEED_DIR/clevel
else
    echo -e "${RED}Valid workload options: pclht, memcached, cceh, fast_fair, clevel${NC}"
    exit 1
fi

echo -e "${GREEN}$1 done.${NC}"
