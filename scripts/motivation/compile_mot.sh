#!/bin/bash

set -x

cur_dir=`readlink -f .`
root_dir=`readlink -f ../..`
motivation_dir=$root_dir/motivation

cd $motivation_dir
gcc mot_appends.c -o mot -O3

cd $cur_dir
