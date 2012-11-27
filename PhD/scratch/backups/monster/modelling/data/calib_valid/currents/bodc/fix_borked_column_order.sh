#!/bin/bash

# I need the data as:
#   YYYY,MM,DD,HH,MM,SS,DIR,SPEED
# Some sites have the last two columns the wrong way around. 
# This script fixes that.

#files=(b0431353.csv b0431377.csv b0431389.csv b0444413.csv b0564323.csv)
files=(b0431353.csv b0431377.csv b0431389.csv b0444413.csv)

for ((i=0; i<${#files[@]}; i++)); do
    echo -n "Working on ./raw_data/${files[i]}... "
    awk -F"," '{OFS=","; print $1,$2,$3,$4,$5,$6,$8,$7}' ./raw_data/${files[i]} > \
        ./raw_data/${files[i]%.*}_fixed.csv
    mv ./raw_data/${files[i]} ./raw_data/old/${files[i]}
    mv ./raw_data/${files[i]%.*}_fixed.csv ./raw_data/${files[i]}
    echo "done."
done
