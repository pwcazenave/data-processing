#!/bin/bash

# Script to extract the full times from the lst files for each site (necessary
# for comparisons with model output).

echo site,year,month,day,hour,minute,second > all_times.txt

for file in raw_data/*.lst; do
    startdate=$(grep start: $file | cut -f2 -d:)
    enddate=$(grep end: $file | cut -f3 -d:)
    if [ -z $enddate ]; then
        enddate=$startdate
    fi
    echo $(basename $file .lst),${startdate:0:4},${startdate:4:2},${startdate:6:2},${startdate:8:2},${startdate:10:2},${startdate:12:2},${enddate:0:4},${enddate:4:2},${enddate:6:2},${enddate:8:2},${enddate:10:2},${enddate:12:2} >> all_times.txt
done
