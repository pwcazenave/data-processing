#!/bin/bash

# Get the locations of the SHOM tide stations.

echo "latDD,lonDD,shortName,longName" > shelf_stations.csv
echo -n > shelf_stations_sql.csv

grep -v + ./meta_info/station.info | \
    tr -d " " | \
    tr "," "/" | \
    grep . | \
    awk -F"|" '{OFS=","}{if (NR>1) print $4,$3,$5,$2}' \
    >> shelf_stations_sql.csv

# Append the sql version to the GIS version
cat shelf_stations_sql.csv >> shelf_stations.csv

