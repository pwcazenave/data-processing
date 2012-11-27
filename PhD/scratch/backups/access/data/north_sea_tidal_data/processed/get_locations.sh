#!/bin/bash

# extract the coordinates and site names of the water level data from the
# north sea tidal data files in ./raw_data

echo "eastings,northings,siteNum,siteName,startDate,startTime,endDate,endTime,durationDays,durationHours,interval,waterLevel,timeReference,waterReference" > ./locations_all.csv
files=(raw_data/*.OBS)

for ((i=0; i<${#files[@]}; i++)); do
   # which file are we on?
   echo -n "Working on ${files[$i]}... "
   # get the location
   coords=$(grep GEOGRAPH ${files[$i]} | tr "[A-Z/=]" " " | awk '{print $2,$1}')
   # get the site info for the sites that have it
   startTime=$(grep PERIOD\ BEGIN ${files[$i]} | awk 'BEGIN{FS="=| "};{print $4}')
   startDate=$(grep PERIOD\ BEGIN ${files[$i]} | awk 'BEGIN{FS="=| "};{print $3}')
   endTime=$(grep PERIOD\ END ${files[$i]} | awk 'BEGIN{FS="=| "};{print $4}')
   endDate=$(grep PERIOD\ END ${files[$i]} | awk 'BEGIN{FS="=| "};{print $3}')
   interval=$(grep REGISTRATION\ INTERVAL= ${files[$i]} | cut -f2 -d"=")
   waterLevel=$(grep WATER\ DEPTH ${files[$i]} | cut -f2 -d"=")
   timeRef=$(grep TIME\ REFERENCE ${files[$i]} | cut -f2 -d"=")
   waterRef=$(grep REFERENCE\ LEVEL\ MEASUREMENT ${files[$i]} | cut -f2 -d"=")
   durationDays=$(grep PERIOD\ DURATION ${files[$i]} | awk 'BEGIN{FS="=| "};{print $3}')
   durationHours=$(grep PERIOD\ DURATION ${files[$i]} | awk 'BEGIN{FS="=| "};{print $4}')

   if [ ${files[$i]:9:1} -eq "0" ]; then
      siteName=$(grep DATA\ SOURCE\ CODE ${files[$i]} | cut -f2 -d=)
   else
      siteName=$(grep STATION\ NAME ${files[$i]} | cut -f2 -d=)
   fi

   if [ -z $waterLevel ]; then
      waterLevel=NaN
   fi

   # add the file name as the identifier (site) to the location file
   echo ${coords//\ /,},\
      $(basename ${files[i]} .OBS),\
      ${siteName//\ /_},\
      ${startDate:0:4}/${startDate:4:2}/${startDate:6:2},\
      ${startTime:0:2}:${startTime:2:2}:${startTime:4:2},\
      ${endDate:0:4}/${endDate:4:2}/${endDate:6:2},\
      ${endTime:0:2}:${endTime:2:2}:${endTime:4:2},\
      ${durationDays},\
      $(echo "scale=2; ${durationHours:0:2}+(${durationHours:2:2}/60)"\
         | bc -l),\
      ${interval},\
      ${waterLevel},\
      ${timeRef},\
      ${waterRef} | \
      tr -d " \t" >> ./locations_all.csv
   # status closure
   echo "done."
done

exit 0
