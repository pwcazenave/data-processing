#!/bin/bash

# script to convert the coordinate strings into DD from DMS

echo lonDD,latDD,site > locations_latlong_proper.csv
cut \
   -c1-3,4-5,6-9,11-12,13-14,15-18,20- \
   --output-delimiter=" " \
   locations.csv | \
   sed '1d' | \
   awk '{printf "%.7f,%.7f,%s\n", $1+($2/60)+($3/3600), $4+($5/60)+($6/3600),$7}' >> locations_latlong_proper.csv

echo lonDD,latDD,site > locations_all_proper.csv
cut \
   -c1-3,4-5,6-9,11-12,13-14,15-18,20- \
   --output-delimiter=" " \
   locations.csv | \
   sed '1d' | \
   awk '{printf "%.7f,%.7f,%s\n", $1+($2/60)+($3/3600), $4+($5/60)+($6/3600),$7}' >> locations_all_proper.csv
