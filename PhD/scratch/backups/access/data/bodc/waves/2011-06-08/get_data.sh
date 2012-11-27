#!/bin/bash

# Get the relevant headers and data for the sites of interest.

for i in $(cut -f1 -d, wave_locations_uniques.csv); do
    cp ./headers/$i.lst ./selected/headers
    cp ./formatted/$i.lst ./selected
done

# Format the selected files based on the columns in
# wave_locations_uniques_edited.csv (added by manually examining the headers
# for the sites of interest and identifying the appropriate columns.
cat wave_locations_uniques_edited.csv | while read line; do
    col1=$(echo $line | cut -f5 -d,)
    col2=$(echo $line | cut -f6 -d,)
    currFile=$(echo $line | cut -f1 -d,)
    awk '{print $2,$3,$'$col1',$'$col2'}' ./selected/$currFile.lst \
        > ./selected/formatted/$currFile.lst
done
