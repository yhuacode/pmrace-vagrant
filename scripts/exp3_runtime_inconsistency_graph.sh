#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# set environment variables
source /home/vagrant/scripts/env.sh

DEBUG_SCRIPT_PATH=/home/vagrant/scripts/debug_workload.sh
PYTHON_SCRIPT_PATH=$PMRACE_DIR/scripts/gen_err_graph.py
PM_WORKLOADS_DIR=/home/vagrant/pm-workloads
SEED_DIR=/home/vagrant/seeds/full
RESULT_FOLDER=/home/vagrant/download/results
mkdir -p $RESULT_FOLDER

PCLHT_WORK_DIR=$PM_WORKLOADS_DIR/RECIPE/P-CLHT/build
FF_WORK_DIR=$PM_WORKLOADS_DIR/FAST_FAIR/concurrent_pmdk
MEMCACHED_WORK_DIR=$PM_WORKLOADS_DIR/memcached-pmem

# ensure the libPMRaceHook.so is the pre-failure version
cd $PMRACE_DIR/instrument
rm -f libPMRaceHook.so
make

# ###########################################################
# # fuzzing pclht using Delay Inj
cd $PCLHT_WORK_DIR
$PMRACE_DIR/scripts/clear.sh                   # clear the results of previous tests
rm -rf output-random
SKIP_PM_IMG_BACKUP=1 timeout 3h python3 $PMRACE_DIR/scripts/fuzz.py -e p-clht -d ./CMakeFiles/driver.dir -p $PMRACE_DIR/deps/pmdk -s $SEED_DIR/pclht -m random
mv output output-random

# fuzzing pclht using PMRace's strategy
$PMRACE_DIR/scripts/clear.sh                   # clear the results of previous tests
rm -rf output-pmrace
SKIP_PM_IMG_BACKUP=1 timeout 3h python3 $PMRACE_DIR/scripts/fuzz.py -e p-clht -d ./CMakeFiles/driver.dir -p $PMRACE_DIR/deps/pmdk -s $SEED_DIR/pclht -m pmrace
mv output output-pmrace

# plot the figure of pclht
python3 $PYTHON_SCRIPT_PATH output-random output-pmrace $RESULT_FOLDER/pclht.png $RESULT_FOLDER/pclht.csv


###########################################################
# fuzzing fast-fair using Delay Inj
# cd $FF_WORK_DIR
# $PMRACE_DIR/scripts/clear.sh                   # clear the results of previous tests
# rm -rf output-random
# SKIP_PM_IMG_BACKUP=1 timeout 3h python3 $PMRACE_DIR/scripts/fuzz.py -e fast-fair -d ./ -p $PMRACE_DIR/deps/pmdk -s $SEED_DIR/ff -m random
# mv output output-random

# # fuzzing fast-fair using PMRace's strategy
# $PMRACE_DIR/scripts/clear.sh                   # clear the results of previous tests
# rm -rf output-pmrace
# SKIP_PM_IMG_BACKUP=1 timeout 3h python3 $PMRACE_DIR/scripts/fuzz.py -e fast-fair -d ./ -p $PMRACE_DIR/deps/pmdk -s $SEED_DIR/ff -m pmrace
# mv output output-pmrace

# # plot the figure of fast-fair
# python3 $PYTHON_SCRIPT_PATH output-random output-pmrace $RESULT_FOLDER/ff.png $RESULT_FOLDER/ff.csv

###########################################################
# # fuzzing memcached using Delay Inj

# # kill zombie processes of memcached
# killall -9 memcached 2>/dev/null

# cd $MEMCACHED_WORK_DIR
# $PMRACE_DIR/scripts/clear.sh                   # clear the results of previous tests
# rm -rf output-random
# SKIP_PM_IMG_BACKUP=1 timeout 15h python3 $PMRACE_DIR/scripts/fuzz.py -e memcached -d ./ -p $PMRACE_DIR/deps/pmdk -s $SEED_DIR/memcached -m random
# mv output output-random

# # kill zombie processes of memcached
# killall -9 memcached 2>/dev/null

# # fuzzing memcached using PMRace's strategy
# $PMRACE_DIR/scripts/clear.sh                   # clear the results of previous tests
# rm -rf output-pmrace
# SKIP_PM_IMG_BACKUP=1 timeout 15h python3 $PMRACE_DIR/scripts/fuzz.py -e memcached -d ./ -p $PMRACE_DIR/deps/pmdk -s $SEED_DIR/memcached -m pmrace
# mv output output-pmrace

# # kill zombie processes of memcached
# killall -9 memcached 2>/dev/null

# # plot the figure of memcached-pmem
# python3 $PYTHON_SCRIPT_PATH output-random output-pmrace $RESULT_FOLDER/memcached.png $RESULT_FOLDER/memcached.csv

