#!/bin/bash

cur_dir=`readlink -f ./`

# Run MICRO
cd micro
taskset -c 0-7 ./run_micro.sh
cd $cur_dir

# Run FACTOR
cd factor
taskset -c 0-7 ./run_factor.sh
cd $cur_dir

# Run WORST
cd worst
taskset -c 0-7 ./run_worst.sh
cd $cur_dir

# Run MOT
cd motivation
taskset -c 0-7 ./run_mot.sh
cd $cur_dir

