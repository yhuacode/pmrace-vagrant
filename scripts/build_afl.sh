#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# set environment variables
source /home/vagrant/scripts/env.sh

cd /home/vagrant
git clone https://github.com/pmem/pmdk.git
git clone https://github.com/AFLplusplus/AFLplusplus.git
git clone https://github.com/mrash/afl-cov.git
git clone https://github.com/yhuacode/pmrace-mutator.git pmrace-mutator
git clone https://github.com/yhuacode/pm-workloads.git pm-workloads-afl-build

cd /home/vagrant/pmdk
git checkout tags/1.9
git apply ../scripts/pmdk.diff
make EXTRA_CFLAGS="-mclflushopt -mclwb" CXX=$LLVM_DIR/bin/clang++ CC=$LLVM_DIR/bin/clang DEBUG=1 BUILD_EXAMPLES=n BUILD_BENCHMARKS=n BUILD_RPMEM=n NDCTL_ENABLE=n AVX512F_AVAILABLE=n -j
make EXTRA_CFLAGS="-mclflushopt -mclwb" CXX=$LLVM_DIR/bin/clang++ CC=$LLVM_DIR/bin/clang DEBUG=1 BUILD_EXAMPLES=n BUILD_BENCHMARKS=n BUILD_RPMEM=n NDCTL_ENABLE=n AVX512F_AVAILABLE=n -j install prefix=/home/vagrant/pmdk/install

cd /home/vagrant/AFLplusplus
git checkout 78d96c4dc8
make CXX=$LLVM_DIR/bin/clang++ CC=$LLVM_DIR/bin/clang source-only

cd /home/vagrant/pm-workloads-afl-build
git checkout afl-build
git submodule init && git submodule update --progress

cd /home/vagrant/pmrace-mutator
mkdir pools
mkdir output
cp -r /home/vagrant/seeds/corpus .

# /home/vagrant/afl-cov/afl-cov -d /home/vagrant/pmrace-mutator/output/out_memcached/ --coverage-cmd "cat AFL_FILE | LD_LIBRARY_PATH=/home/vagrant/pmdk/install/lib/pmdk_debug /home/vagrant/pm-workloads-afl-build/memcached-pmem/memcached-debug -A -o pslab_force,pslab_file=/home/vagrant/pmrace-mutator/pools/mem_pool" --code-dir /home/vagrant/pm-workloads-afl-build/memcached-pmem --overwrite

# To fuzz, first source /home/vagrant/pmrace-mutator/afl_env.sh, then make test-[workload]
