#!/bin/bash

# Convert the dbf to a csv
( cd ../ && rm ./all_4m_points.csv; dbf2csv all_4m_points.dbf )

# Remove extraneous whitespace from csv file
sed -i 's/\ //g' ../all_4m_points.csv

# Separate the input CSV file into annual files
rm ????.?? || true
awk -F, '{print $0 >> $3}' ../all_4m_points.csv
rm ./Year || true

echo "year,eastings,northings" > centroids.csv
for i in ????.??; do
    awk -F"," '{totalX+=$(NF-1);totalY+=$NF} END {name='"$i"'; printf "%s,%.2f,%.2f\n", name,totalX/NR,totalY/NR}' $i >> centroids.csv
done
