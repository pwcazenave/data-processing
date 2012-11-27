#!/bin/bash

# script to rename the csv files according to their start date and station name
# so it's easier to cat them into year files.

obsFiles=(raw_data/*OBS)
csvFiles=(raw_data/python/*csv)

for ((file=0;file<${#obsFiles[@]};file++)); do
   startTime=$(grep PERIOD\ BEGIN ${obsFiles[$file]} | awk 'BEGIN{FS="=| "};{print $4}')
   endTime=$(grep PERIOD\ END ${obsFiles[$file]} | awk 'BEGIN{FS="=| "};{print $4}')
   startDate=$(grep PERIOD\ BEGIN ${obsFiles[$file]} | awk 'BEGIN{FS="=| "};{print $3}')
   endDate=$(grep PERIOD\ END ${obsFiles[$file]} | awk 'BEGIN{FS="=| "};{print $3}')
   # get the site info for the sites that have it
   if [ ${obsFiles[$file]:9:1} -eq "0" ]; then
      site=$(grep DATA\ SOURCE\ CODE ${obsFiles[$file]} | cut -f2 -d=)
   else
      site=$(grep STATION\ NAME ${obsFiles[$file]} | cut -f2 -d=)
   fi
   cp ${csvFiles[$file]} ./formatted/new_names/${site//\ /}_${startDate}_${csvFiles[$file]##*/}
done
