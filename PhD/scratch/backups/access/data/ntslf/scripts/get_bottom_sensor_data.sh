#!/bin/bash

# script to extract and format the bodc pressure data in the Data_to_extract.txt
# format for the Matlab code...
# Also creates a line with start and end time etc. for Data_to_extract.txt

sites=(33748 33761 33736 33797 40929 40942 40954 33804 40966 40978 40991 41005 41029 41030 41042 41054 41134 41146)
groups=(25 25 25 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26)
rawDir=./bottom_pressure_sensor_data
procDir=${rawDir}/processed
dataToExtract=$procDir/Data_to_extract.txt
ext=.dat
extDone=.csv

if [ -e $dataToExtract ]; then
   rm -f $dataToExtract
fi

for ((i=0;i<${#sites[@]};i++)); do
   if [ -e $rawDir/b00${sites[$i]}${ext} ]; then

      sed -n '/^\ Number/,$p' $rawDir/b00${sites[$i]}${ext} | awk 'BEGIN{FS="[/.:\t ]+"};{if (NR>1) printf "%4i,%02i,%02i,%02i,%02i,%02i,%5.2f\n", $3,$4,$5,$6,$7,$8,$9,$10}' > $procDir/${groups[$i]}_${sites[$i]}${extDone}
      startTime=$(awk '/Start:/ {print $2,$3}' $rawDir/b00${sites[$i]}${ext} | \
         tr ":" " " | cut -f2 -d" ")
      endTime=$(awk '/Start:/ {print $2,$3}' $rawDir/b00${sites[$i]}${ext} | \
         tr ":" " " | cut -f4 -d" ")
      latDD=$(grep ${sites[$i]} ./bodc_historical_pressure_sensor_metainfo.csv | \
         cut -f1 -d",")
      longDD=$(grep ${sites[$i]} ./bodc_historical_pressure_sensor_metainfo.csv | \
         cut -f2 -d",")
      sensorDepth=$(grep ${sites[$i]} ./bodc_historical_pressure_sensor_metainfo.csv | \
         cut -f6 -d",")
      # output the format string for Data_to_extract.txt
      echo ${groups[$i]} ${sites[$i]} ${startTime:0:4} ${startTime:4:2} ${startTime:6:2} ${endTime:0:4} ${endTime:4:2} ${endTime:6:2} ${sensorDepth} $latDD $longDD >> $dataToExtract
   fi
done
