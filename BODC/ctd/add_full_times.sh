#!/bin/bash

# Add the full times to the metadata in all_stations.sh. Run get_full_times.sh
# to first extract the times.

# I'd have been better off writing this in Python as I'd forgotten how horribly
# slow bash is for this sort of stuff. Hey ho.

set -e

# The new header (has "Start time" inserted after "Start date").
echo '"BODC reference","Oceanographic data type",Instrument,Platform,"Latitude A","Latitude B","Longitude A","Longitude B","Positional definition","Start date","Start time","End date","Series duration (days)","Sea floor depth (m)","Series depth minimum (m)","Series depth maximum (m)",Project,Country,Organisation,"Quality control (QC)","Series availability",Warnings,Licence' > new_all_stations.csv

while read line; do
    site=$(echo $line | cut -f1 -d,)

    if [ "$site" != '"BODC reference"' ]; then
        filename=$(printf "b%07i" $site)

        csvDate=$(echo $line | cut -f10 -d, | tr -d "-" | tr -d "/")

        # Find the current site's times and insert into the CSV file after the Start date.
        startDate=$(grep $filename all_times.txt | awk -F, '{printf "%04i%02i%02i\n", $2,$3,$4}')
        startTime=$(grep $filename all_times.txt | awk -F, '{printf "%02i:%02i:%02i\n", $5,$6,$7}')

        diffDate=$(echo "scale=2; $startDate - $csvDate" | bc -l)
        if [ $diffDate -ne 0 ]; then
            echo "Warning: something's amiss with the dates for site $filename ($csvDate vs. $startDate)"
            startTime="00:00:00"
        fi

        # Now export to CSV
        for ((i=0; i<22; i++)); do
            col=$(echo $line | cut -f$(($i + 1)) -d,)
            if [ $i -eq 9 ]; then
                echo -n "$col", >> new_all_stations.csv
                echo -n "$startTime", >> new_all_stations.csv
            elif [ $i -eq 21 ]; then
                echo "$col" >> new_all_stations.csv
            else
                echo -n "$col", >> new_all_stations.csv
            fi
        done
    fi

done < all_stations.csv

