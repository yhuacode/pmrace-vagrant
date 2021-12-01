#!/bin/bash
apt-get update
apt-get -y install build-essential autoconf cmake pkg-config ninja-build \
                git python3 python3-dev python3-pip \
                m4 pandoc libndctl-dev libdaxctl-dev \
                libelf-dev elfutils libdw-dev libunwind-dev \
                libboost-all-dev libpapi-dev default-jdk \
                libtbb-dev libjemalloc-dev libevent-dev \
                libjpeg-dev zlib1g-dev lcov

su -c /home/vagrant/scripts/setup.sh vagrant