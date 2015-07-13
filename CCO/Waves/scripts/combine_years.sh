#!/bin/bash

# Combine the annual data files into a single file per site.

sites=($(ls -1 raw_data/*.txt | cut -f2 -d_ | cut -f2 -d\/ | sort -u))

for ((i=0; i<${#sites[@]}; i++)); do
    echo -n "Working on site ${sites[i]}... "
    raw=(raw_data/${sites[i]}*.txt)
    head -n1 ${raw[0]} > clean/${sites[i]}.txt
    for f in ${raw[@]}; do
        tail -q -n +2 $f >> clean/${sites[i]}.txt
    done
    echo "done."
done
