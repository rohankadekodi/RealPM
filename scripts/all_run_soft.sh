#!/bin/bash

cur_dir=`readlink -f ./`

# Run YCSB
cd ycsb
taskset -c 0-7 ./run_ycsb_soft.sh
cd $cur_dir

# Run TPCC
cd tpcc
taskset -c 0-7 ./run_tpcc_soft.sh
cd $cur_dir

