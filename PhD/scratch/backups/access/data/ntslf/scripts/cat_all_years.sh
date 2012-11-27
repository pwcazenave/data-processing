#!/bin/bash

declare -a years rawyears

raw_data=./bodc_archive_all
rawyears=( $(cd $raw_data; ls *.txt | cut -c1-4 | sort -u) )
places=( $(cd $raw_data; ls *.txt | cut -c5- | sort -u) )

for ((loc=0; loc<${#places[@]}; loc++)); do
   echo ${places[$loc]}
   awk 'NF {print $2,$3,$4,$5}' $raw_data/*${places[loc]} | grep \/ | \
      tr -d "[A-Z]" > ./${raw_data}/catted/${places[loc]}
done
