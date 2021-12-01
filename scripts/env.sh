#!/bin/bash

if [[ -z "${PMEM_IS_PMEM_FORCE}" ]]; then
    export PMEM_IS_PMEM_FORCE=1
    export LLVM_DIR=/home/vagrant/llvm-11
    export PATH=$LLVM_DIR/bin:$PATH
    export PMRACE_DIR=/home/vagrant/pmrace
fi