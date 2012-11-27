#!/bin/bash

# script to extract the start and end dates of each survey

count=1;
total=$(ls meta_info/documentation/*.htm|wc -l)

echo "start the extraction... "
echo "site_no,latDD,longDD,start,end,duration,instrument_type,mounting_type,instrument_depth_m,datum,sampling_interval,orginator_identifier" \
   > ./meta_info/metadata_all_duration.csv
for i in ./meta_info/documentation/*.htm; do
   echo -en "\b\b\b\b\b\b\b\b\b\b\b\b"
   echo -n "$count of $total"
   # get the instrument type
   type=$(sed -e :a -e 's/<[^>]*>/\n/g;/</N;//ba' $i | \
      grep -A2 Instrument\ Type | tail -n 1)
   # get the locations
   latlong=$(sed -e :a -e 's/<[^>]*>/\n/g;/</N;//ba' $i | \
      grep -E -A2 tude | grep deg | tr "\n" " " | \
      awk '{print $1, $9, $10}')
   coords=$(echo $latlong | \
      awk '{if ($3 == "W") print $1","($2*-1); else print $1","$2}')
   # get the instrument mounting
   mount=$(sed -e :a -e 's/<[^>]*>/\n/g;/</N;//ba' $i | \
      grep -A2 Instrument\ Mounting | tail -n 1)
   # get the instrument depth
   depth=$(sed -e :a -e 's/<[^>]*>/\n/g;/</N;//ba;s/\ m//g' $i | \
      grep -A2 Sea\ Floor\ Depth | head -n 3 | tail -n 1)
   # get the depth datum
   datum=$(sed -e :a -e 's/<[^>]*>/\n/g;/</N;//ba' $i | \
      grep -A2 Sea\ Floor\ Depth\ Datum | tail -n 1)
   # get the start time
   start=$(tr "<" "\n" < $i | \
      grep -A2 Start\ Time\ | tail -n 1 | sed 's/td>\ //')
   # get the end time
   end=$(tr "<" "\n" < $i | \
      grep -A2 End\ Time\ | tail -n 1 | sed 's/td>//')
   # calculate the duration of the dataset
   startF=$(echo $start | tr "-" "/")
   startS=$(date -d "$startF" +%s)
   endF=$(echo $end | tr "-" "/")
   endS=$(date -d "$endF" +%s)
   duration=$(echo "$endS - $startS" | bc -l)
   durationD=$(echo "scale=4; $duration/86400" | bc -l)
   # get the sampling interval
   interval=$(sed -e :a -e 's/<[^>]*>/\n/g;/</N;//ba' $i | \
      grep -A2 Nominal\ Cycle\ Interval | tail -n 1)
   # originator's identifier
   ident=$(sed -e :a -e 's/<[^>]*>/\n/g;/</N;//ba' $i | \
      grep -A2 Originator\'s\ Identifier | tail -n 1)
   # create csv file
   echo $(basename $i .htm),$coords,$start,$end,$durationD,$type,$mount,$depth,$datum,$interval,$ident \
      >> ./meta_info/metadata_all_duration.csv
   ((count++))
done
echo ""
echo "done."

exit 0
