#!/bin/bash

SCRIPT_PATH=/home/vagrant/scripts/build_workload.sh

$SCRIPT_PATH pclht
$SCRIPT_PATH memcached
$SCRIPT_PATH cceh
$SCRIPT_PATH fast_fair
$SCRIPT_PATH clevel
