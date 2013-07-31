#!/bin/bash

# Script to extract the full times from the lst files for each site (necessary
# for comparisons with model output).

echo site,year,month,day,hour,minute,second > all_times.txt

for file in raw_data/*.lst; do
    fulldate=$(grep start: $file | cut -f2 -d:)
    echo $(basename $file .lst),${fulldate:0:4},${fulldate:4:2},${fulldate:6:2},${fulldate:8:2},${fulldate:10:2},${fulldate:12:2} >> all_times.txt
done
