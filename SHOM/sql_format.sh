#!/bin/bash

# Add the short and long name of each tide station to the raw data so it's
# easier to import into the SQL database.

for file in ./formatted/f*.slv; do
    # Get the long name from shelf_stations_sql.csv
    # Remove the f from each of the short names
    shortName=$(echo $file | cut -f3 -d'/' | cut -f1 -d. | cut -f2- -df)
    longName=$(grep $shortName ./shelf_stations_sql.csv | cut -f4- -d,)
    awk '{OFS=","}{print $0,"'$shortName'","'$longName'"}' $file > ./formatted/sql/$(basename ${file%.*}_sql.slv)
done
