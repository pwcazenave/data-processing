#!/bin/bash

# Get the locations of the NTSLF tide stations.

files=($(\ls -1 raw_data/*.txt | cut -f2 -d'/' | tr -d "[0-9]" | cut -f1 -d. | sort -u))

echo "latDD,lonDD,shortName,longName" > shelf_stations.csv
echo -n > shelf_stations_sql.csv

for ((i=0; i<${#files[@]}; i++)); do
    currFile=$(\ls -1 raw_data/*${files[i]}.txt | tail -1) # use the most recent position
    lat=$(head -20 $currFile | grep Latitude: | cut -f2 -d: | tr -d " ")
    lon=$(head -20 $currFile | grep Longitude: | cut -f2 -d: | tr -d " ")
    site=$(head -20 $currFile | grep Site: | cut -f2 -d: | tr -d " ")
    echo "$lat,$lon,${files[i]},$site" >> shelf_stations.csv
    echo "$lat,$lon,${files[i]},$site" >> shelf_stations_sql.csv
done

