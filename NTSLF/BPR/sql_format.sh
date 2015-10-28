#!/bin/bash

# Add the short and long name of each tide station to the raw data so it's
# easier to import into the SQL database.

for file in ./formatted/*.{dat,lst}; do
    # Get the long name from shelf_stations_sql.csv
    shortName=$(echo $file | cut -f3 -d'/' | cut -f1 -d.)
    shortName=$(grep $shortName ./shelf_stations_sql.csv | cut -f4- -d, | tr -d "\n")
    awk -F, '{OFS=" "}{print $1,$2,$3,$4,$5,$6,-$7,"'$shortName'"}' $file > ./formatted/sql/$(basename ${file%.*}_sql.txt)
done
