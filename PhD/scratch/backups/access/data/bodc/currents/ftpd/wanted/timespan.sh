#!/bin/bash

# script to extract the start and end dates of each survey

echo -n "start the extraction... "
echo "start_date,start_time,end_date,end_time,site_no" > ./timings.csv
for i in ../../meta_info/*.htm; do
   # get the start
   start=$(tr "<" "\n" < $i | \
      grep -A2 Start\ Time\ | tail -n 1 | sed 's/td>\ //')
   # get the end
   end=$(tr "<" "\n" < $i | \
      grep -A2 End\ Time\ | tail -n 1 | sed 's/td>//')
   echo $(echo $start | tr " " ","),$(echo $end | tr " " ","),$(basename $i .htm) >> ./timings.csv
done
echo "done."

exit 0
