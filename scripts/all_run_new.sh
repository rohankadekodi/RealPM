#!/bin/bash

cur_dir=`readlink -f ./`

# Run TAR
cd tar
taskset -c 0-7 ./run_tar.sh
cd $cur_dir

# Run GIT
cd git
taskset -c 0-7 ./run_git.sh
cd $cur_dir

# Run REDIS
#cd redis
#taskset -c 0-7 ./run_redis.sh
#cd $cur_dir

