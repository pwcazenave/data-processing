#!/bin/bash

# Create files for all available years for a single station.

sites=($(\ls -1 raw_data/*.txt | cut -f2 -d'/' | tr -d "[0-9]" | cut -f1 -d. | sort -u))

for ((i=0; i<${#sites[@]}; i++)); do
    cat formatted/????${sites[i]}.txt | grep -v '  ' > ./formatted/${sites[i]}.txt
done
