#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# set environment variables
source /home/vagrant/scripts/env.sh

# build PMRace
echo -e "${GREEN}Build PMRace${NC}"
git clone https://github.com/yhuacode/pmrace.git /home/vagrant/pmrace/
cd /home/vagrant/pmrace

# Install python libs for tests
pip3 install -r requirements.txt

git submodule init && git submodule update --progress

cd $PMRACE_DIR/deps/pmdk
git apply ../../patches/pmdk.diff

# build the pass
cd $PMRACE_DIR/instrument
make

# build PMDK
make pmdk
