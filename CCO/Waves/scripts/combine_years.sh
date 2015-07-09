#!/bin/bash

# Combine the annual data files into a single file per site.

sites=($(ls -1 raw_data/*.txt | cut -f2 -d_ | cut -f2 -d\/ | sort -u))

for ((i=0; i<${#sites[@]}; i++)); do
    echo -n "Working on site ${sites[i]}..."
    cat raw_data/${sites[i]}*.txt > annual/${sites[i]}.txt
    echo "done."
done
