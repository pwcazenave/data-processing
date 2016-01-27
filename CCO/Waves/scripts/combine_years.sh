#!/bin/bash

# Combine the annual data files into a single file per site.

sites=($(ls -1 raw_data/*.txt | cut -f2 -d_ | cut -f2 -d\/ | sort -u))

for ((i=0; i<${#sites[@]}; i++)); do
    # Get its longname so we can use that as the key for the database.
    site=$(grep -a ${sites[i]} locations.csv | cut -f3 -d,)
    echo -n "Working on site ${site}... "
    raw=(raw_data/${sites[i]}*.txt)
    head -n1 ${raw[0]} > clean/${site}.txt
    for f in ${raw[@]}; do
        tail -q -n +2 $f >> clean/${site}.txt
    done
    echo "done."
done
