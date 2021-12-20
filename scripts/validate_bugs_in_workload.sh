#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# set environment variables
source /home/vagrant/scripts/env.sh

PM_WORKLOADS_DIR=/home/vagrant/pm-workloads
BUILD_SCRIPT_PATH=/home/vagrant/scripts/build_workload.sh

# ensure the libPMRaceHook.so is the post-failure version
cd $PMRACE_DIR/instrument
if [[ -e libPMRaceHook.so ]] && [[ -e libPMRaceHook-PostFailure.so ]] && [[ $(sha1sum libPMRaceHook.so | cut -d " " -f 1) == $(sha1sum libPMRaceHook-PostFailure.so | cut -d " " -f 1) ]]
then
    echo -e "libPMRaceHook.so is the post-failure version."
else
    echo -e "${GREEN}Change libPMRaceHook.so to the post-failure version. ${NC}"
    rm -f libPMRaceHook.so
    make validate
fi

echo -e "${GREEN}Validating $1 ${NC}"

if [ "$1" == "pclht" ]
then
    # RECIPE
    cd $PM_WORKLOADS_DIR/RECIPE/P-CLHT/build
    rm -rf validate
    $PMRACE_DIR/scripts/clear_states_only.sh       # clear the results of previous tests
    python3 $PMRACE_DIR/scripts/fuzz.py -e p-clht -d ./CMakeFiles/driver.dir -p $PMRACE_DIR/deps/pmdk --validate
elif [ "$1" == "memcached" ]
then
    # memcached-pmem

    # kill zombie processes of memcached
    killall -9 memcached 2>/dev/null || true

    cd $PM_WORKLOADS_DIR/memcached-pmem
    rm -rf validate
    $PMRACE_DIR/scripts/clear_states_only.sh       # clear the results of previous tests
    python3 $PMRACE_DIR/scripts/fuzz.py -e memcached -d ./ -p $PMRACE_DIR/deps/pmdk --validate

    # kill zombie processes of memcached
    killall -9 memcached 2>/dev/null || true
elif [ "$1" == "cceh" ]
then
    # CCEH
    cd $PM_WORKLOADS_DIR/CCEH/CCEH-PMDK
    rm -rf validate
    $PMRACE_DIR/scripts/clear_states_only.sh       # clear the results of previous tests
    python3 $PMRACE_DIR/scripts/fuzz.py -e cceh -d ./ -p $PMRACE_DIR/deps/pmdk --validate
elif [ "$1" == "fast_fair" ]
then
    # FAST_FAIR
    cd $PM_WORKLOADS_DIR/FAST_FAIR/concurrent_pmdk
    rm -rf validate
    $PMRACE_DIR/scripts/clear_states_only.sh       # clear the results of previous tests
    python3 $PMRACE_DIR/scripts/fuzz.py -e fast-fair -d ./ -p $PMRACE_DIR/deps/pmdk --validate
elif [ "$1" == "clevel" ]
then
    # Clevel-Hashing
    echo -e "Since no PM concurrency bugs were found in clevel hashing
and the recovery logic was not implemented in the original source code,
skip the validation for clevel hashing"
else
    echo -e "${RED}Valid workload options: pclht, memcached, cceh, fast_fair${NC}"
    exit 0
fi

echo -e "${GREEN}$1 done.${NC}"
