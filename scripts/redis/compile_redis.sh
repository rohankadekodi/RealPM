#!/bin/bash

set -x

cur_dir=`readlink -f ./`
src_dir=`readlink -f ../../`
redis_dir=$src_dir/redis-4.0.10

cd $redis_dir
make distclean
cd deps

#cd jemalloc
#./autogen.sh
#cd ..

make hiredis jemalloc linenoise lua geohash-int
cd ..

sudo make install

cd $cur_dir
