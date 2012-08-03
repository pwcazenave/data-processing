#!/bin/bash

# Having identified the SHOM data contain nonsense time and date values, this
# script drops the relevant tables and puts the data back in.

while read line; do
    station=$(echo $line | cut -f3 -d,)

    # Add the data
    if [ -f ./formatted/f${station}.slv ]; then
        currFile=./formatted/f${station}.slv
        delim=','
    else
        echo "Metadata for ${station} is present, but data file is not. Skipped"
        continue
    fi

    # Drop the existing table
    echo -n "Dropping $station... "
    sqlite3 ../proc/tides/tides.db << SQL
DROP TABLE ${station};
SQL

    # Create the table again
    echo -n "recreating table... "
    sqlite3 ../proc/tides/tides.db << SQL
CREATE TABLE ${station}(
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

    echo -n "importing $currFile... "
        sqlite3 ../proc/tides/tides.db << SQL
.separator "$delim"
.import $currFile $station
SQL
    echo "done."
done < ./shelf_stations_sql_edited.csv

