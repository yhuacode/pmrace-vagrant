#!/bin/bash

SCRIPT_PATH=/home/vagrant/scripts/debug_workload.sh

timeout 5m $SCRIPT_PATH pclht sample
timeout 5m $SCRIPT_PATH clevel sample
timeout 5m $SCRIPT_PATH cceh sample
timeout 10m $SCRIPT_PATH fast_fair sample
timeout 20m $SCRIPT_PATH memcached sample
