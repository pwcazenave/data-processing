#!/bin/bash

# Add the full times to the metadata in all_stations.sh. Run get_full_times.sh
# to first extract the times.

# I'd have been better off writing this in Python as I'd forgotten how horribly
# slow bash is for this sort of stuff. Hey ho.

set -e

infile=all_stations.csv
outfile=new_${infile}
infile=port_erin.csv
outfile=new_${infile}

# The new header (has "Start time" and "End time" inserted after "Start date" and "End date", respectively).
echo '"BODC reference","Oceanographic data type",Instrument,Platform,"Latitude A","Latitude B","Longitude A","Longitude B","Positional definition","Start date","Start time","End date","End time","Series duration (days)","Sea floor depth (m)","Series depth minimum (m)","Series depth maximum (m)",Project,Country,Organisation,"Quality control (QC)","Series availability",Warnings,Licence' > $outfile

while read line; do
    site=$(echo $line | cut -f1 -d,)

    if [ "$site" != '"BODC reference"' ]; then
        filename=$(printf "b%07i" $site)

        csvDate=$(echo $line | cut -f10 -d, | tr -d "-" | tr -d "/")

        # Find the current site's times and insert into the CSV file after the Start date.
        startDate=$(grep $filename all_times.txt | awk -F, '{printf "%04i%02i%02i\n", $2,$3,$4}')
        startTime=$(grep $filename all_times.txt | awk -F, '{printf "%02i:%02i:%02i\n", $5,$6,$7}')
        endDate=$(grep $filename all_times.txt | awk -F, '{printf "%04i%02i%02i\n", $8,$9,$10}')
        endTime=$(grep $filename all_times.txt | awk -F, '{printf "%02i:%02i:%02i\n", $11,$12,$13}')

        # If we have empty end dates, replace with -99 (no data value).
        if [ -z $endDate ]; then
            endDate=-99
        fi
        if [ -z $endTime ]; then
            endTime=-99
        fi

        diffDate=$(echo "scale=2; $startDate - $csvDate" | bc -l)
        if [ $diffDate -ne 0 ]; then
            echo "Warning: something's amiss with the dates for site $filename ($csvDate vs. $startDate)"
            startTime="00:00:00"
        fi

        # Now export to CSV
        for ((i=0; i<22; i++)); do
            col=$(echo $line | cut -f$(($i + 1)) -d,)
            if [ $i -eq 9 ]; then
                echo -n "$col", >> $outfile
                echo -n "$startTime", >> $outfile
            elif [ $i -eq 10 ]; then
                #echo -n "$col", >> $outfile
                echo -n "${endDate:0:4}/${endDate:4:2}/${endDate:6:2}", >> $outfile
                echo -n "$endTime", >> $outfile
            elif [ $i -eq 21 ]; then
                echo "$col" >> $outfile
            else
                echo -n "$col", >> $outfile
            fi
        done
    fi

done < $infile

