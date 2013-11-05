#!/bin/bash

# Script to export the regional files to individual files for each site.

for file in single/??_data0.txt; do
    prefix=${file:7:2}

    if [ ! -d multi/$prefix ]; then
        mkdir multi/$prefix
    fi

    (
        cd multi/$prefix
        awk -F, '{OFS=","}{print $0 >> $2".csv"}' ../../$file
    )

done
