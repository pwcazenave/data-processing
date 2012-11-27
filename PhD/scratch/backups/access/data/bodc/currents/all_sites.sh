#!/bin/bash
#
# script to strip and format all the cmd/*.lst files.
# yyyy mm dd hh mm ss dir mag
#
# data_to_extract.dat contains the filenames to extract ($2) and the group they
# are a part of ($1)
#

#set -x

data=./cmd
output=./output/all_sites_formatted
count=1

\rm -f $output/depth_info.csv

for file in ./cmd/*.lst; do
   grep Depth:\ floor $file | awk '{print $2,$3,$4,$5}' | tr " " "," \
      > ./depth
   awk 'FNR>19{print $2","$3}' $file | \
      tr -d "[A-Z]" | tr "/." "," > ./tad
   awk 'FNR>19{print $4","$5}' $file | \
      tr -d "[A-Z]" > ./info
   paste -d ',' ./tad ./info > "$output"/"$(basename $file .lst)".csv
   echo $file,$(<./depth) >> $output/depth_info.csv
#   echo $group $(printf %g $file) AA > ./interim_values
   rm -f ./tad ./info ./depth #./interim_values
   ((count++))
done

exit 0
