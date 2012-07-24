#!/bin/bash

# script to convert the coordinate strings into DD from DMS

echo "lonDD,latDD,siteNum,siteName,startDate,startTime,endDate,endTime,durationDays,durationHours,interval,waterLevel,timeReference,waterReference" > shelf_stations_latlong.csv

cut \
   -c1-2,3-4,5-8,10-12,13-14,15-18,20- \
   --output-delimiter=" " \
   shelf_stations.csv | \
   sed '1d' | \
   awk '{printf "%.7f,%.7f,%s\n", $1+($2/60)+($3/3600), $4+($5/60)+($6/3600),$7}' >> shelf_stations_latlong_sql.csv

cat shelf_stations_latlong_sql.csv >> shelf_stations_latlong.csv
