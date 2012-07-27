#!/bin/bash

# Run the sql script to create the database, and then populate with the NTSLF
# and SHOM data.

# Create the database and add the meta data (see create_sql.sql for details on
# adding extra metadata.
sqlite3 ../proc/tides/tides.db < create_sql.sql

# Now add the NTSLF data
for file in ./formatted/sql/???_sql.txt; do
    echo -n "Adding $file... "
    sqlite3 ../proc/tides/tides.db << SQL
.separator ' '
.import $file Tides
SQL
    echo 'done.'
done

# Now add the SHOM data
for file in ../SHOM/formatted/sql/f*_sql.slv; do
    echo -n "Adding $file... "
    sqlite3 ../proc/tides/tides.db << SQL
.separator ','
.import $file Tides
SQL
    echo 'done.'
done

# Add the meta data
echo -n "Add metadata... "
for file in ./shelf_stations_sql.csv ../SHOM/shelf_stations_sql.csv; do
    sqlite3 ../proc/tides/tides.db << SQL
.separator ','
.import $file Stations
SQL
done
echo 'done.'
