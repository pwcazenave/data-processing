#!/bin/bash

# Script to extract positions and shallow vs. deep stations

outlocations=./gloup_locations.csv

echo "latDD,longDD,depth,duration,name,id" > $outlocations

count=1
total=$(\ls -1 ./raw_data/deeper_than_200m/*.dat ./raw_data/shallower_than_200m/*.dat | wc -l)

for i in ./raw_data/deeper_than_200m/*.dat ./raw_data/shallower_than_200m/*.dat; do
   echo "Working on $count of $total."; count=$(($count+1))
   latDD=$(head -20 "$i" | grep "North latitude" | awk '{print $1}')
   lonDD=$(head -20 "$i" | grep "East longitude" "$i" | awk '{print $1}')
   if [ -z "$latDD" ] || [ -z "$lonDD" ]; then
      echo "Didn't get the lat or long - check everything's ok with the input"
      break
   fi
   name=$(head -20 "$i" | grep "Name:" "$i" | cut -f2 -d\  )
   id=$(basename ${i%.dat})
   depth=$(head -20 "$i" | grep "Depth            (metres)" $i | awk '{print $1}')
   # Duration is number of samples * sampling inverval. Result is in hours
   duration=$(head -20 "$i" | grep "Sample interval  (hours); Number of data entries" "$i" | awk '{print $1*$2}')
   echo "$latDD,$lonDD,$depth,$duration,$name,$id" >> $outlocations
done
