#!/bin/bash

# script to get the info needed for the "data to extract.txt" file

allFiles=(./formatted/*.csv)

group=1

if [ -e ./dataToExtractNew.txt ]; then
   rm ./dataToExtractNew.txt
fi

for ((i=0; i<${#allFiles[@]}; i++)); do
   startDate=$(head -n1 ${allFiles[$i]} | cut -f1-3 -d",")
   endDate=$(tail -n1 ${allFiles[$i]} | cut -f1-3 -d",")
   siteNumber=$(echo ${allFiles[$i]} | tr "_./" " " | cut -f4 -d" ")
   instrumentDepth=$(grep 'WATER DEPTH=' ./raw_data/$(basename ${allFiles[$i]} .csv).OBS | cut -f2 -d"=")
   latDD=$(grep $siteNumber ./locations_all_proper.csv | cut -f2 -d"," | tr -d "\r")
   longDD=$(grep $siteNumber ./locations_all_proper.csv | cut -f1 -d"," | tr -d "\r")
   if [ -z $instrumentDepth ]; then
      instrumentDepth=0
   fi
   fileName=$(basename ${allFiles[$i]%.csv})

   echo $group ${siteNumber//Z/} ${startDate//,/\ } ${endDate//,/\ } $instrumentDepth $longDD $latDD $fileName >> ./dataToExtract.txt
done

