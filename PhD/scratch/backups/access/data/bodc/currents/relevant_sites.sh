#!/bin/bash
#
# script to extract the relevant files for dave's analysis and rename them
# according to their timespan.
#
# data_to_extract.dat contains the filenames to extract ($2) and the group they
# are a part of ($1)
#

#set -x

#list=./data_to_extract.dat
#list=./Data\ to\ extract3.txt
#list=./Data\ to\ extract2.txt
#list=./data_to_extract_cropped.txt
#list=./Data\ to\ extract3_cropped.txt
list=./input_lists/goodwin_sands_calib.txt
data=./cmd
output=./output/goodwin_sands_calib/
count=1
total=$(wc -l $list | cut -f1 -d" ")

if [ -e "${list%.txt}_with_depths.txt" ]; then
   \rm -f "${list%.txt}_with_depths.txt"
   touch "${list%.txt}_with_depths.txt"
fi

echo "site,latD,longD,seabed,seabed_depth,sensor,sensor_depth,start_date,start_time,end_date,end_time,duration" > "${list%.txt}_with_depths.txt"

for file in $(awk '{printf "%07d\n", $2}' "$list"); do

   # print status
   echo -en "\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b"
   echo -n "$count of $total..."

   # get Dave's random group info from the input file
   group=$(awk '{print $1}' "$list" | sed -n ''$count'p')

   # get depth info
   depth=$(grep Depth:\ floor $data/b$file.lst | awk '{print $2,$3,$4,$5}')
   tr -d "MN" < $data/b$file.lst | grep -v "[A-Z]" | \
      grep -v "[a-z]" | tr "./" "," | \
      awk '{print $4","$5}' | awk -F, '{print $1"."$2","$3"."$4}' > ./info

   # get time and date
   tr -d "MN" < $data/b$file.lst | grep -v "[A-Z]" | \
      grep -v "[a-z]" | tr "./" "," | \
      awk '{print $2","$3}' > ./tad
   paste -d ',' ./tad ./info > "$output"/"$group"_"$file".csv
   meta=$(echo $group $(printf %g $file))

   # get start and end times and durations
   startT=$(head -1 ./tad | awk -F, '{print $1"/"$2"/"$3,$4":"$5":"$6}')
   startS=$(date -d "$startT" +%s)
   endT=$(tail -1 ./tad | awk -F, '{print $1"/"$2"/"$3,$4":"$5":"$6}')
   endS=$(date -d "$endT" +%s)
   duration=$(echo "scale=4; ($endS - $startS)/86400" | bc -l)

   # get position from htm documentation
   latD=$(sed -e :a -e 's/<[^>]*>/\n/g;/</N;//ba' \
      ./meta_info/documentation/$(printf %g $file).htm | grep . | \
       grep -A1 Latitude | cut -f1 -d" " | sed -n '2p')
   longD=$(sed -e :a -e 's/<[^>]*>/\n/g;/</N;//ba' \
      ./meta_info/documentation/$(printf %g $file).htm | grep . | \
      grep -A1 Longitude | awk '{if ($2=="W") print $1*-1; else print $1}' \
      | sed -n '2p')
   latlongD=$(echo $latD,$longD)

   # output all the information to a csv file
   echo $meta $latlongD $depth $startT $endT $duration | \
      awk '{OFS=","; print $2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12}' \
      >> "${list%.txt}_with_depths.txt"

   # clean up
   rm -f ./tad ./info

   ((count++))

done

exit 0
