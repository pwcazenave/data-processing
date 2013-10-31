#!/bin/bash

# Script to convert the new file name conventions to the old ones.

while read line; do
    new=$(echo $line | cut -f3 -d, | tr "'." "_")
    old=$(echo $line | cut -f4 -d, | sed "s/\./\._/g" | tr -d "'")
    mv -i ${old}_20120101_20130101.csv 2012${new}.csv
done < ../shelf_stations_sql.csv
