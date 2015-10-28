#!/bin/bash

# Strip out the locations from the headers in the raw data. Also get the
# series name.

files=(./raw_data/*.dat ./raw_data/*.lst)

echo "latDD,lonDD,seriesName" > shelf_stations.csv
echo "latDD,lonDD,seriesName" > shelf_stations_model_domain.csv
echo -n > shelf_stations_sql.csv

for ((i=0; i<${#files[@]}; i++)); do
    series=$(echo ${files[i]} | cut -f3 -d'/' | cut -f1 -d'.' | tr -d 'b')
    posRaw=$(grep -i Start ${files[i]} | sed -e 's/^[ \t]*//' | cut -f1 -d' ' | tr "dm" " " | sed 's/N/N\ /g')
    latDD=$(echo $posRaw | awk '{if ($3=="N") fix=1; else fix=-1}END{print ($1+($2/60))*fix}')
    lonDD=$(echo $posRaw | awk '{if ($6=="E") fix=1; else fix=-1}END{print ($4+($5/60))*fix}')
    echo "$latDD,$lonDD,b$series,$(printf %g $series)" >> ./shelf_stations_sql.csv
done

cat shelf_stations_sql.csv >> shelf_stations.csv

# Get values within the shelf model domain only (with a 2 degree buffer)
awk -F, '{if ($1>43 && $1<67 && $2>-17 && $2<17) print $0}' shelf_stations_sql.csv >> shelf_stations_model_domain.csv
