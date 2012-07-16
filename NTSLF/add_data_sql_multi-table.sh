#!/bin/bash

# Use the data in the shelf_stations.csv files to create a table for each tide
# station. This way, accessing a particular site's data shouldn't require
# trawling through the entire database every time. Instead, we can just pull
# the appropriate table from the database.

for file in ./shelf_stations_sql.csv ../SHOM/shelf_stations_sql.csv; do
    while read line; do
        station=$(echo $line | cut -f3 -d,)
        if [ -z $station ]; then
            # Need to use the long name for the table name
            echo "WARNING: No short name given. Usually because SHOM metadata has more stations that data available. Skipped."
            continue
        fi
        sqlite3 tides_multitable.db << SQL
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
        if [ -f ./formatted/${station}.txt ]; then
            currFile=./formatted/${station}.txt
            delim=' '
        elif [ -f ../SHOM/formatted/f${station}.slv ]; then
            currFile=../SHOM/formatted/f${station}.slv
            delim=','
        else
            echo "Metadata for ${station} is present, but data file is not. Skipped"
            continue
        fi

        echo -n "Adding $currFile... "
            sqlite3 tides_multitable.db << SQL
.separator "$delim"
.import $currFile $station
SQL
        echo "done."
    done < $file
done

# Add all the metadata
echo -n "Add metadata... "
sqlite3 tides_multitable.db << STATIONS
CREATE TABLE Stations(
    latDD FLOAT(10),
    lonDD FLOAT(10),
    shortName TEXT COLLATE nocase,
    longName TEXT COLLATE nocase
);
STATIONS
# Populate with the station info
for file in ./shelf_stations_sql.csv ../SHOM/shelf_stations_sql_edited.csv; do
    sqlite3 tides_multitable.db << SQL
.separator ','
.import $file Stations
SQL
done
echo 'done.'
