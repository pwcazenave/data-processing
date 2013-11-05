#!/bin/bash

# Add the positions from the siteInfo.csv file to the metaData.csv file.

meta=tbl_metaData.csv
site=tbl_siteInfo.csv

count=1

dos2unix $meta $site

while read line; do

    # Get the current site ID.
    sID=$(echo $line | cut -f1 -d,)

    if [ $count -eq 1 ]; then
        # Just paste the two headers together.
        echo ${line}$(head -1 $site) > metadata.csv
    else
        # Find the coordinates of the current site.
        coords=$(grep -w ^$sID $site)
        echo $line","$coords >> metadata.csv
    fi

    count=$(($count + 1))

done < $meta
