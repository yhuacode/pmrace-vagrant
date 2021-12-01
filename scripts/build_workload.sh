#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# set environment variables
source /home/vagrant/scripts/env.sh

PM_WORKLOADS_DIR=/home/vagrant/pm-workloads

apply_patch_on_workload() {
    # apply patch
    # usage: build_workload <workload> <path>
    echo -e "${GREEN}Apply the patch of $2 ${NC}"
    cd $PM_WORKLOADS_DIR/$2
    $PM_WORKLOADS_DIR/patches/apply_patches.sh $1
    echo -e "${GREEN}Start to build $1 ${NC}"
}

if [ "$1" == "pclht" ]
then
    # RECIPE
    apply_patch_on_workload "RECIPE" "RECIPE"

    # build
    mkdir -p P-CLHT/build
    cd P-CLHT/build
    cmake -DCMAKE_BUILD_TYPE=Debug ..
    make
elif [ "$1" == "memcached" ]
then
    # memcached-pmem
    apply_patch_on_workload "memcached" "memcached-pmem"

    # build
    autoreconf
    CC=clang CXX=clang++ ./configure --enable-pslab --enable-pmrace
    make
elif [ "$1" == "cceh" ]
then
    # CCEH
    apply_patch_on_workload "CCEH" "CCEH"

    # build
    cd CCEH-PMDK/
    make
elif [ "$1" == "fast_fair" ]
then
    # FAST_FAIR
    apply_patch_on_workload "FAST_FAIR" "FAST_FAIR"

    # build
    cd concurrent_pmdk/
    make
elif [ "$1" == "clevel" ]
then
    # Clevel-Hashing
    apply_patch_on_workload "clevel" "Clevel-Hashing"

    # build
    mkdir build
    cd build
    cmake -DENABLE_PMRACE=ON ..
    make -j16
else
    echo -e "${RED}Valid workload options: pclht, memcached, cceh, fast_fair, clevel${NC}"
fi

echo -e "${GREEN}$1 done.${NC}"