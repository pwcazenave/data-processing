#!/bin/bash

# use to documentation to get the site locations and indexes

echo -n "start the extraction... "
echo "LatDD, LongDD, Site_No" > doc_locations_new.csv
for i in ./documentation/*.htm; do
   # locations
   tmp1=$(tr "<" "\n" < $i | \
      grep -A2 tude | grep deg | sed 's/td>//' | \
      awk '{print $1, $2}' | tr "\n" " " | \
      awk '{print $1, $3, $4}' | \
      awk '{if ($3 == "W") print $1", "($2*-1); else print $1", "$2}')
   # site numbers - get from filename! duh...
   tmp2=$(echo $(basename $i .htm))
   echo "$tmp1, $tmp2" >> doc_locations_new.csv
done
echo "done."

echo -n "extracting those in the region of interest... "
echo "LatDD, LongDD, Site_No" > subset_new.csv
tr "," " " < doc_locations_new.csv | \
   awk '{if (($2 > -2) && ($1 > 49) && ($1 < 52.5)) print $1", "$2", "$3}' \
   >> subset_new.csv
echo "done."


