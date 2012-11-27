#!/bin/bash

# extract the coordinates and site names of the water level data from the
# north sea tidal data files in ./raw_data
# Also extract the tidal values, add them to the water depth if present, and generate timestamps for the tidal values.

# WARNING: This script is very slow (shell scripting is not ideal for this), so make sure you want to run it before doing so, as it overwrites blindly.

#dos2unix ./raw_data/*.OBS

echo "eastings,northings,site" > ./locations.csv

files=(raw_data/*.OBS)

for ((i=0; i<${#files[@]}; i++)); do
   # which file are we on?
   echo -n "Working on ${files[$i]}... "

   # remove existing files, if present
   if [ -e ${files[$i]%.*}.csv ]; then
      \rm -f ${files[$i]%.*}.csv
   fi
   # get the location
   coords=$(grep GEOGRAPH ${files[$i]} | tr "[A-Z/=]" "\t" | awk '{print $2, $1}')
   # get the dates
   startTime=$(grep PERIOD\ BEGIN ${files[$i]} | awk 'BEGIN{FS="=| "};{print $4}')
   startDate=$(grep PERIOD\ BEGIN ${files[$i]} | awk 'BEGIN{FS="=| "};{print $3}')
#   endTime=$(grep PERIOD\ END ${files[$i]} | awk 'BEGIN{FS="=| "};{print $4}')
#   endDate=$(grep PERIOD\ END ${files[$i]} | awk 'BEGIN{FS="=| "};{print $3}')
   # sampling interval
   interval=$(grep REGISTRATION\ INTERVAL= ${files[$i]} | cut -f2 -d"=")
   # the values
#   data=($(grep -v \[A-Z\] ${files[$i]}))
   data=($(sed -n '/^VALUES/,$p' ${files[$i]} | grep -v VALUES))
   # a water depth on site, if present
   waterLevel=$(grep WATER\ DEPTH ${files[$i]} | cut -f2 -d"=")
   # how many times do I have to do this?
   numRecs=$(grep NUMBER\ OF\ DATA\ RECORDS ${files[$i]} | cut -f2 -d"=")
   # are we in GMT or MET?
   timeRef=$(grep TIME\ REFERENCE ${files[$i]} | cut -f2 -d"=")

   if [ $timeRef == "MET" ]; then
      timeShift=60
   elif [ $timeRef == "GMT" ]; then
      timeShift=0
   else
      echo "Unknown Time Reference"
      exit 1
   fi

   # start from midnight
   if [ $startTime -eq "0" ]; then
      # check if we have a depth on site
      if [ -z $waterLevel ]; then # no, we don't
         for ((j=0; j<${numRecs}; j++)); do
            newFullDate=$(date -d "${startDate:0:4}-${startDate:4:2}-${startDate:6:2} + $((($j*$interval)-$timeShift)) minutes" +%Y,%m,%d,%H,%M,%S)
            echo $newFullDate,${data[$j]} >> ${files[$i]%.*}.csv
         done
      else # water level is non-zero
         for ((j=0; j<${numRecs}; j++)); do
            newFullDate=$(date -d "${startDate:0:4}-${startDate:4:2}-${startDate:6:2} + $((($j*$interval)-$timeShift)) minutes" +%Y,%m,%d,%H,%M,%S)
            if [ ${data[$j]} == "NAN" ]; then # watch out for NANs
               echo $newFullDate,NAN >> ${files[$i]%.*}.csv
            else # NANs
               echo $newFullDate,$(echo "scale=3; (${data[$j]}/100)+$waterLevel" | bc -l) >> ${files[$i]%.*}.csv
            fi # NANs
         done
      fi # water level end
   else # time does not start from midnight
      # calculate number of minutes since midnight of the startDate and add
      # to the date calculation
      if [ ${startTime:0:1} -eq 0 ]; then # hour less than 10 borks the script
         extraMinutes=$(((${startTime:1:2}*60)+${startTime:2:2}))
      else # check hours
         extraMinutes=$(((${startTime:0:2}*60)+${startTime:2:2}))
      fi # check hours
      # check if we have a depth on site
      if [ -z $waterLevel ]; then # no, we don't
         for ((j=0; j<${numRecs}; j++)); do
            newFullDate=$(date -d "${startDate:0:4}-${startDate:4:2}-${startDate:6:2} + $(((($j*$interval)+$extraMinutes)-$timeShift)) minutes" +%Y,%m,%d,%H,%M,%S)
            echo $newFullDate,${data[$j]} >> ${files[$i]%.*}.csv
         done
      else # water level is non-zero
         for ((j=0; j<${numRecs}; j++)); do
            newFullDate=$(date -d "${startDate:0:4}-${startDate:4:2}-${startDate:6:2} + $(((($j*$interval)+$extraMinutes)-$timeShift)) minutes" +%Y,%m,%d,%H,%M,%S)
            if [ ${data[$j]} == "NAN" ]; then # watch out for NANs
               echo $newFullDate,NAN >> ${files[$i]%.*}.csv
            else # NANs
               echo $newFullDate,$(echo "scale=3; (${data[$j]}/100)+$waterLevel" | bc -l) >> ${files[$i]%.*}.csv
            fi # NANs
         done
      fi # water level end
   fi # midnight start time

   # add the file name as the identifier (site) to the location file
   echo $(echo $coords | tr " " "," ),$(basename ${files[i]} .OBS) >> ./locations.csv
   # status closure
   echo "done."
done

exit 0
