#!/bin/bash

set -x

cur_dir=`readlink -f .`
root_dir=`readlink -f ../..`
factor_dir=$root_dir/factor

cd $factor_dir
gcc rw_experiment.c -o factor -O3

cd $cur_dir
