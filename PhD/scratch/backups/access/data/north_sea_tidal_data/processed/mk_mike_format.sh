#!/bin/bash

# Script to convert the csv formatted locations to something mike likes.

infile=./locations_all_metadata_proper.csv
intermediate=./locations_unique_proper.csv
outfile=./locations_unique_proper_mike.xyz

rm $outfile || true

# Get only unique locations
grep -v latDD $infile | \
   cut -f1-2 -d, --output-delimiter=" " | \
   sort -u > $intermediate

num=$(wc -l < $intermediate)

for i in $(seq $num); do
   if [ $i -gt 1 ]; then
      awk -F"," '{if (NR=='$i') print $1,$2,"0 Site_"'$i-1'}' $intermediate \
         >> $outfile
      # Replace NaNs with 0
      sed -i 's/NaN/0/g' $outfile
   fi
done
