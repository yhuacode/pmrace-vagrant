#!/bin/bash
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# set environment variables
source /home/vagrant/scripts/env.sh

# change the *_SEED_DIR to other locations if you like
AFL_SEED_DIR=/home/vagrant/seeds/bak/output_without_membak_and_with_afl/out_memcached-100
PMRACE_SEED_DIR=/home/vagrant/seeds/bak/output_without_membak_and_with_pmrace/out_memcached-100

# build p-clht
cd /home/vagrant/pm-workloads-afl-build
./patches/apply_patches.sh RECIPE
cd RECIPE
mkdir build
cd build
cmake ..
make -j

# build memcached
cd /home/vagrant/pm-workloads-afl-build
./patches/apply_patches.sh memcached
cd memcached-pmem
autoreconf
CC=/home/vagrant/AFLplusplus/afl-clang-fast ./configure --enable-pslab
make -j

# build clevel
cd /home/vagrant/pm-workloads-afl-build
./patches/apply_patches.sh clevel
cd Clevel-Hashing
mkdir build
cd build
cmake ..
make -j

# build fast-fair
cd /home/vagrant/pm-workloads-afl-build
./patches/apply_patches.sh FAST_FAIR
cd FAST_FAIR/concurrent_pmdk
make ENABLE_PMRACE=0 -j

# build cceh
cd /home/vagrant/pm-workloads-afl-build
./patches/apply_patches.sh CCEH
cd CCEH/CCEH-PMDK
make ENABLE_PMRACE=0 -j

###########################################################
# Test the code coverage using afl's seeds
cd /home/vagrant/pmrace-mutator

# kill zombie processes of memcached
killall -9 memcached 2>/dev/null

echo -e "${GREEN}Testing AFL's seeds${NC}"
/home/vagrant/afl-cov/afl-cov -d $AFL_SEED_DIR --coverage-cmd "cat AFL_FILE | LD_LIBRARY_PATH=/home/vagrant/pmdk/install/lib/pmdk_debug /home/vagrant/pm-workloads-afl-build/memcached-pmem/memcached-debug -A -o pslab_force,pslab_file=/home/vagrant/pmrace-mutator/pools/mem_pool" --code-dir /home/vagrant/pm-workloads-afl-build/memcached-pmem --overwrite

# kill zombie processes of memcached
killall -9 memcached 2>/dev/null

echo -e "${GREEN}Testing PMRace's seeds${NC}"
/home/vagrant/afl-cov/afl-cov -d $PMRACE_SEED_DIR --coverage-cmd "cat AFL_FILE | LD_LIBRARY_PATH=/home/vagrant/pmdk/install/lib/pmdk_debug /home/vagrant/pm-workloads-afl-build/memcached-pmem/memcached-debug -A -o pslab_force,pslab_file=/home/vagrant/pmrace-mutator/pools/mem_pool" --code-dir /home/vagrant/pm-workloads-afl-build/memcached-pmem --overwrite

# kill zombie processes of memcached
killall -9 memcached 2>/dev/null

echo -e "${GREEN}AFL's coverage results are presented in $AFL_SEED_DIR/cov/web/memcached-pmem/memcached.c.gcov.html${NC}"
echo -e "${GREEN}PMRace's coverage results are presented in $PMRACE_SEED_DIR/cov/web/memcached-pmem/memcached.c.gcov.html${NC}"

