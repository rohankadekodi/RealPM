#!/bin/bash

ycsb_workloads_dir=/home/rohan/projects/ycsb_workloads

char=z
for i in {1..5}; do
	if [ $i = 1 ]; then
		char=a
	elif [ $i = 2 ]; then
		char=b
	elif [ $i = 3 ]; then
		char=c
	elif [ $i = 4 ]; then
		char=d
	elif [ $i = 5 ]; then
		char=f
	fi
	mv $ycsb_workloads_dir/run${char}_5M_10M $ycsb_workloads_dir/tmp.txt
	sed -n '1,2500000p' $ycsb_workloads_dir/tmp.txt > $ycsb_workloads_dir/run${char}_50M_5M_1
	sed -n '2500001,5000000p' $ycsb_workloads_dir/tmp.txt > $ycsb_workloads_dir/run${char}_50M_5M_2
	sed -n '5000001,7500000p' $ycsb_workloads_dir/tmp.txt > $ycsb_workloads_dir/run${char}_50M_5M_3
	sed -n '7500001,10000000p' $ycsb_workloads_dir/tmp.txt > $ycsb_workloads_dir/run${char}_50M_5M_4
	rm $ycsb_workloads_dir/tmp.txt
done

char=z
for i in {1..2}; do
        if [ $i = 1 ]; then
                char=a
        elif [ $i = 2 ]; then
                char=e
        fi
        mv $ycsb_workloads_dir/load${char}_5M $ycsb_workloads_dir/tmp.txt
        sed -n '1,1250000p' $ycsb_workloads_dir/tmp.txt > $ycsb_workloads_dir/load${char}_50M_1
        sed -n '1250001,2500000p' $ycsb_workloads_dir/tmp.txt > $ycsb_workloads_dir/load${char}_50M_2
        sed -n '2500001,3750000p' $ycsb_workloads_dir/tmp.txt > $ycsb_workloads_dir/load${char}_50M_3
        sed -n '3750001,5000000p' $ycsb_workloads_dir/tmp.txt > $ycsb_workloads_dir/load${char}_50M_4
        rm $ycsb_workloads_dir/tmp.txt
done

char=e
mv $ycsb_workloads_dir/run${char}_5M_25M $ycsb_workloads_dir/tmp.txt
sed -n '1,625000p' $ycsb_workloads_dir/tmp.txt > $ycsb_workloads_dir/run${char}_50M_25M_1
sed -n '625001,1250000p' $ycsb_workloads_dir/tmp.txt > $ycsb_workloads_dir/run${char}_50M_25M_2
sed -n '1250001,1875000p' $ycsb_workloads_dir/tmp.txt > $ycsb_workloads_dir/run${char}_50M_25M_3
sed -n '1875001,2500000p' $ycsb_workloads_dir/tmp.txt > $ycsb_workloads_dir/run${char}_50M_25M_4
rm $ycsb_workloads_dir/tmp.txt
