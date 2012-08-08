#!/bin/bash

# Use the data in the shelf_stations.csv files to create a table for each tide
# station. This way, accessing a particular site's data shouldn't require
# trawling through the entire database every time. Instead, we can just pull
# the appropriate table from the database.

for file in ./shelf_stations_sql.csv; do
    while read line; do
        station=$(echo $line | cut -f3 -d,)
        if [ -z $station ]; then
            # Need to use the long name for the table name
            echo "WARNING: No short name given. Usually because SHOM metadata has more stations that data available. Skipped."
            continue
        fi
        sqlite3 ../../proc/tides/tides.db << SQL
CREATE TABLE $station(
    year INT,
    month INT,
    day INT,
    hour INT,
    minute INT,
    second INT,
    elevation FLOAT(10),
    residual FLOAT(10),
    quality TEXT COLLATE nocase
);
SQL

        # Add the data
        if [ -f ./formatted/${station}.dat ]; then
            currFile=./formatted/${station}.dat
            delim=' '
        else
            echo "Metadata for ${station} is present, but data file is not. Skipped"
            continue
        fi

        echo -n "Adding $currFile... "
            sqlite3 ../../proc/tides/tides.db << SQL
.separator "$delim"
.import $currFile $station
SQL
        echo "done."
    done < $file
done

# Add all the metadata
echo -n "Add metadata... "
# Populate with the station info
for file in ./shelf_stations_sql.csv; do
    sqlite3 ../../proc/tides/tides.db << SQL
.separator ','
.import $file Stations
SQL
done
echo "done."