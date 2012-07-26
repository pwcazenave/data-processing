#!/bin/bash

# Complimentary script to get_locations.sh, this will find the start and end
# dates for a given record. The results need to be merged together manually at
# the end.

for file in raw_data/TOTAL/*.slv; do
    startEnd=($(minmax -C -fT $file --INPUT_DATE_FORMAT="yyyy-mm-dd" --INPUT_CLOCK_FORMAT="hh:mm:ss" | awk '{print $1,$2}'))
    echo $(basename $file .slv),${startEnd[0]},${startEnd[1]} >> ./shelf_stations_time_sql.csv
done

echo "station,startDate,endDate" > ./shelf_stations_time.csv
cat ./shelf_stations_time_sql.csv >> ./shelf_stations_time.csv
