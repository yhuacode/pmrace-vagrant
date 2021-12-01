#!/bin/bash

SCRIPT_PATH=/home/vagrant/scripts/validate_bugs_in_workload.sh

$SCRIPT_PATH pclht
$SCRIPT_PATH cceh
$SCRIPT_PATH fast_fair
$SCRIPT_PATH memcached
