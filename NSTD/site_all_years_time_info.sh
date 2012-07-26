#!/bin/bash

# Get the start and end times for each station for all years. Requires
# the single_site.sh script to have been run and the data placed in
# ./formatted. See README.txt for more information.

# Using the existing edited metadata, create a unique list of the sites
# to form the basis for the new meta data file.
sort -uk1,2 -t, shelf_stations_latlong_edited_sql.csv \
    > shelf_stations_latlong_edited_sql_uniques.csv

echo "latDMS,lonDMS,siteNum,siteName,startDate,startTime,endDate,endTime,durationDays,durationHours,interval,waterLevel,timeReference,waterReference" > ./shelf_stations_single_years.csv
echo -n > ./shelf_stations_single_years_sql.csv

while read line; do
    file=./formatted/$(echo $line | cut -f4 -d,).txt
    base=$(echo $line | cut -f4 -d,)
    echo -n "Station $base... "

    # Use GMT's minmax to get a start and end time for each station
    startEnd=($(awk -F, '{print $1"-"$2"-"$3"T"$4":"$5":"$6}' "$file" | \
        minmax -fT -C | \
        tr "T" " "))

    # Also need to calculate new duration values
    newDaysHours=($(grep $base -w ./shelf_stations_latlong_edited.csv | awk -F, '{sumDays += $9+($10/24)}END{print int(sumDays), (sumDays-int(sumDays))*24}'))
    # Replace the start/end dates and times in the existing line with the
    # new ones from here.
    echo $line | \
        awk -F, '{OFS=","; print $1,$2,$3,$4,"'${startEnd[0]}'","'${startEnd[1]}'","'${startEnd[2]}'","'${startEnd[3]}'","'${newDaysHours[0]}'","'${newDaysHours[1]}'",$11,$12,$13,$14}' \
        >> ./shelf_stations_single_years_sql.csv

    echo "done."
done < shelf_stations_latlong_edited_sql_uniques.csv

cat ./shelf_stations_single_years_sql.csv >> ./shelf_stations_single_years.csv
