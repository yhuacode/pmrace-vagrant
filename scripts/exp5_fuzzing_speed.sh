#!/bin/bash

RED='\033[0;320m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# set environment variables
source /home/vagrant/scripts/env.sh
source /home/vagrant/scripts/afl_env.sh

reset_and_apply() {
    git reset --hard
    git clean -xfd
    git apply /home/vagrant/pm-workloads-afl-build/patches/$1.diff
}

X_LINE=10

cal_fuzz_speed() {
    # cal_fuzz_speed plot_data_path
    LINES=$(wc -l $1 | cut -f1 -d " ")
    if (( LINES < X_LINE )); then
        # echo "Too small plot_data[$1]: $LINES"
	return -1
    fi

    START_T=$(sed -n 2p $1 | cut -f1 -d ",")
    END_T=$(awk "NR==$X_LINE" $1 | cut -f1 -d ",")
    TOTAL_EXECS=$(awk "NR==$X_LINE" $1 | cut -f12 -d ",")

    FIRST_COL_NAME=$(sed -n 1p $1 | cut -f1 -d ",")
    if [ "$FIRST_COL_NAME" == "# unix_time" ]; then
        SPEED=$(echo "scale=2; $TOTAL_EXECS / ( $END_T - $START_T ) " | bc -l)
    elif [ "$FIRST_COL_NAME" == "# relative_time" ]; then
        SPEED=$(echo "scale=2; $TOTAL_EXECS / $END_T " | bc -l)
    else
        echo -e "${RED}Unknown format: $1${NC}"
        exit 1
    fi
    echo "$SPEED"
}

###########################################################
# build pm-workloads with in-memory checkpoint
echo -e "${GREEN}Re-building pm-workloads with in-memory checkpoint${NC}"

# build p-clht
cd /home/vagrant/pm-workloads-afl-build
cd RECIPE
reset_and_apply RECIPE
mkdir build
cd build
cmake ..
make -j

# build memcached
cd /home/vagrant/pm-workloads-afl-build
cd memcached-pmem
reset_and_apply memcached-pmem-with-membak
autoreconf
CC=/home/vagrant/AFLplusplus/afl-clang-fast ./configure --enable-pslab
make -j

# build clevel
cd /home/vagrant/pm-workloads-afl-build
cd Clevel-Hashing
reset_and_apply Clevel-Hashing
mkdir build
cd build
cmake ..
make -j

# build fast-fair
cd /home/vagrant/pm-workloads-afl-build
cd FAST_FAIR
reset_and_apply FAST_FAIR
cd concurrent_pmdk
make ENABLE_PMRACE=0 -j

# build cceh
cd /home/vagrant/pm-workloads-afl-build
cd CCEH
reset_and_apply CCEH
cd CCEH-PMDK
make ENABLE_PMRACE=0 -j


###########################################################
# AFL with in-memory checkpoint
echo -e "${GREEN}Testing AFL with in-memory checkpoint${NC}"
cd /home/vagrant/pmrace-mutator
rm -rf output
rm -rf output_with*
mkdir output

timeout 20m make test-clht USE_AFL=1
timeout 20m make test-ff USE_AFL=1
timeout 20m make test-cceh USE_AFL=1
timeout 20m make test-clevel USE_AFL=1
timeout 20m make test-memcached USE_AFL=1

mv output output_with_membak_and_afl


###########################################################
# PMRace mutator with in-memory checkpoint
echo -e "${GREEN}Testing PMRace with in-memory checkpoint${NC}"
mkdir output

timeout 20m make test-clht
timeout 20m make test-ff
timeout 20m make test-cceh
timeout 20m make test-clevel
timeout 20m make test-memcached

mv output output_with_membak_and_pmrace


###########################################################
# build pm-workloads without in-memory checkpoint
echo -e "${GREEN}Re-building pm-workloads without in-memory checkpoint${NC}"

# build p-clht
cd /home/vagrant/pm-workloads-afl-build
cd RECIPE
reset_and_apply RECIPE-without-membak
mkdir build
cd build
cmake ..
make -j

# build memcached
cd /home/vagrant/pm-workloads-afl-build
cd memcached-pmem
reset_and_apply memcached-pmem
autoreconf
CC=/home/vagrant/AFLplusplus/afl-clang-fast ./configure --enable-pslab
make -j

# build clevel
cd /home/vagrant/pm-workloads-afl-build
cd Clevel-Hashing
reset_and_apply Clevel-Hashing-without-membak
mkdir build
cd build
cmake ..
make -j

# build fast-fair
cd /home/vagrant/pm-workloads-afl-build
cd FAST_FAIR
reset_and_apply FAST_FAIR-without-membak
cd concurrent_pmdk
make ENABLE_PMRACE=0 -j

# build cceh
cd /home/vagrant/pm-workloads-afl-build
cd CCEH
reset_and_apply CCEH-without-membak
cd CCEH-PMDK
make ENABLE_PMRACE=0 -j


###########################################################
# AFL without in-memory checkpoint
echo -e "${GREEN}Testing AFL without in-memory checkpoint${NC}"
cd /home/vagrant/pmrace-mutator
rm -rf output
mkdir output

timeout 20m make test-clht USE_AFL=1
timeout 20m make test-ff USE_AFL=1
timeout 20m make test-cceh USE_AFL=1
timeout 20m make test-clevel USE_AFL=1
timeout 20m make test-memcached USE_AFL=1

mv output output_without_membak_and_with_afl


###########################################################
# PMRace mutator without in-memory checkpoint
echo -e "${GREEN}Testing PMRace without in-memory checkpoint${NC}"
mkdir output

timeout 20m make test-clht
timeout 20m make test-ff
timeout 20m make test-cceh
timeout 20m make test-clevel
timeout 20m make test-memcached

mv output output_without_membak_and_with_pmrace

PCLHT_AFL_W=$(cal_fuzz_speed ./output_with_membak_and_afl/out_clht/default/plot_data)
FF_AFL_W=$(cal_fuzz_speed ./output_with_membak_and_afl/out_ff/default/plot_data)
CCEH_AFL_W=$(cal_fuzz_speed ./output_with_membak_and_afl/out_cceh/default/plot_data)
CLEVEL_AFL_W=$(cal_fuzz_speed ./output_with_membak_and_afl/out_clevel/default/plot_data)
MEMCACHED_AFL_W=$(cal_fuzz_speed ./output_with_membak_and_afl/out_memcached/default/plot_data)

PCLHT_PMRACE_W=$(cal_fuzz_speed ./output_with_membak_and_pmrace/out_clht/default/plot_data)
FF_PMRACE_W=$(cal_fuzz_speed ./output_with_membak_and_pmrace/out_ff/default/plot_data)
CCEH_PMRACE_W=$(cal_fuzz_speed ./output_with_membak_and_pmrace/out_cceh/default/plot_data)
CLEVEL_PMRACE_W=$(cal_fuzz_speed ./output_with_membak_and_pmrace/out_clevel/default/plot_data)
MEMCACHED_PMRACE_W=$(cal_fuzz_speed ./output_with_membak_and_pmrace/out_memcached/default/plot_data)

PCLHT_AFL_WO=$(cal_fuzz_speed ./output_without_membak_and_with_afl/out_clht/default/plot_data)
FF_AFL_WO=$(cal_fuzz_speed ./output_without_membak_and_with_afl/out_ff/default/plot_data)
CCEH_AFL_WO=$(cal_fuzz_speed ./output_without_membak_and_with_afl/out_cceh/default/plot_data)
CLEVEL_AFL_WO=$(cal_fuzz_speed ./output_without_membak_and_with_afl/out_clevel/default/plot_data)
MEMCACHED_AFL_WO=$(cal_fuzz_speed ./output_without_membak_and_with_afl/out_memcached/default/plot_data)

PCLHT_PMRACE_WO=$(cal_fuzz_speed ./output_without_membak_and_with_pmrace/out_clht/default/plot_data)
FF_PMRACE_WO=$(cal_fuzz_speed ./output_without_membak_and_with_pmrace/out_ff/default/plot_data)
CCEH_PMRACE_WO=$(cal_fuzz_speed ./output_without_membak_and_with_pmrace/out_cceh/default/plot_data)
CLEVEL_PMRACE_WO=$(cal_fuzz_speed ./output_without_membak_and_with_pmrace/out_clevel/default/plot_data)
MEMCACHED_PMRACE_WO=$(cal_fuzz_speed ./output_without_membak_and_with_pmrace/out_memcached/default/plot_data)

echo -e "\n\t\t${GREEN}The impact of checkpoints in fuzzing speed${NC} (Hz)\n"
printf "%16s\t%14s%14s%14s%14s\n" " " "PMRace w/" "AFL++ w/" "PMRace w/o" "AFL++ w/o"

printf "%16s\t%14.2f%14.2f%14.2f%14.2f\n" "P-CLHT"         $PCLHT_PMRACE_W $PCLHT_AFL_W $PCLHT_PMRACE_WO $PCLHT_AFL_WO
printf "%16s\t%14.2f%14.2f%14.2f%14.2f\n" "FAST-FAIR"      $FF_PMRACE_W  $FF_AFL_W  $FF_PMRACE_WO $FF_AFL_WO
printf "%16s\t%14.2f%14.2f%14.2f%14.2f\n" "CCEH"           $CCEH_PMRACE_W  $CCEH_AFL_W  $CCEH_PMRACE_WO $CCEH_AFL_WO
printf "%16s\t%14.2f%14.2f%14.2f%14.2f\n" "Clevel Hashing" $CLEVEL_PMRACE_W  $CLEVEL_AFL_W  $CLEVEL_PMRACE_WO $CLEVEL_AFL_WO
printf "%16s\t%14.2f%14.2f%14.2f%14.2f\n" "memcached-pmem" $MEMCACHED_PMRACE_W  $MEMCACHED_AFL_W  $MEMCACHED_PMRACE_WO $MEMCACHED_AFL_WO
