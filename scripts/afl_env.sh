#!/bin/bash

if [[ -z "${AFL_I_DONT_CARE_ABOUT_MISSING_CRASHES}" ]]; then
    export AFL_I_DONT_CARE_ABOUT_MISSING_CRASHES=1
    export AFL_SKIP_CPUFREQ=1
    export AFL_CUSTOM_MUTATOR_ONLY=1
    export AFL_DISABLE_TRIM=1
    export LD_LIBRARY_PATH=/home/vagrant/pmdk/install/lib/pmdk_debug
fi
