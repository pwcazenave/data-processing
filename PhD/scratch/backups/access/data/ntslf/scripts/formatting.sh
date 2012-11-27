#!/bin/bash

# extract the tidal station locations
echo "latDD,longDD,siteName" > ./output/tidal_locations_formatted.txt
for file in ./meta_info/*.html; do
   grep -A3 tude\ of $file | \
   grep deg | grep -v Prior | \
   tr "\n\42\47\46\73" " " | \
   tr -d "[A-D][F-V][X-Z][a-z]:</>()-" | \
   awk 'OFS=","
   {
      if ($1>1900) {
         if ($9==W) {
            print $2+(($3+($4/60))/60),($6+(($7+($8/60))/60))*-1,"'${file##*/}'"
         } else {
            print $2+(($3+($4/60))/60),$6+(($7+($8/60))/60),"'${file##*/}'"
         }
      } else {
         if ($7==W) {
            print $1+(($2+($3/60))/60),($4+(($5+($6/60))/60))*-1,"'${file##*/}'"
         } else {
            print $1+(($2+($3/60))/60),$4+(($5+($6/60))/60),"boo","'${file##*/}'"
         }
      }
   }' | \
   sed 's/.html//g' >> ./output/tidal_locations_formatted.txt
done
