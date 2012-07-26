#!/bin/bash

# Get the locations of the NTSLF tide stations.

files=($(\ls -1 raw_data/*.txt.bz2 | cut -f2 -d'/' | tr -d "[0-9]" | cut -f1 -d. | sort -u))

echo "latDD,lonDD,shortName,longName" > shelf_stations.csv
echo "latDD,lonDD,shortName,longName,startDate,endDate" > shelf_stations_time.csv
echo -n > shelf_stations_sql.csv

for ((i=0; i<${#files[@]}; i++)); do
    currFile=$(\ls -1 raw_data/*${files[i]}.txt.bz2 | tail -1) # use the most recent position
    earlyFile=$(\ls -1 raw_data/*${files[i]}.txt.bz2 | head -1) # for the start time value
    lat=$(pbzcat $currFile | head -20 | grep Latitude: | cut -f2 -d: | tr -d " ")
    lon=$(pbzcat $currFile | head -20 | grep Longitude: | cut -f2 -d: | tr -d " ")
    site=$(pbzcat $currFile | head -20 | grep Site: | cut -f2 -d: | tr -d " ")
    startDate=$(pbzcat $earlyFile | head -20 | grep Start\ Date: | cut -f2 -d: | tr -d " ")
    endDate=$(pbzcat $currFile | head -20 | grep End\ Date: | cut -f2 -d: | tr -d " ")
    echo "$lat,$lon,${files[i]},$site" >> shelf_stations_sql.csv
    echo "$lat,$lon,${files[i]},$site,$startDate,$endDate" >> shelf_stations_time.csv
done

cat shelf_stations_sql.csv >> shelf_stations.csv

