#!/bin/bash

# Take all the individual year files and concatenate them into a single
# file for each station. Use the siteName value in
# shelf_stations_latlong.csv as the basis for each output file name.

# Need to account for the multiple DDH sites when outputting a single for each
# site. Although DDH is listed several times, the coordinates are different
# for each instance. As such, then need to be separate sites, particularly as
# these are the most offshore sites in the data set (in the southern North
# Sea).
listOfSites=($(sort -uk1,2 -t, shelf_stations_latlong.csv | cut -f4 -d, | grep -v siteName))

for ((s=0; s<${#listOfSites[@]}; s++)); do

    if [ "${listOfSites[s]}" == 'DDH' ]; then
        # We have to treat DDH sites carefully as they're all down as the same
        # name in the metainfo but actually have different locations.
        listOfFiles=($(sort -uk1,2 -t, shelf_stations_latlong.csv | sed -n $(($s+1))p | cut -f3 -d,))
    else
        listOfFiles=($(grep ${listOfSites[s]} shelf_stations_latlong.csv | sort -k5 -t, | cut -f3 -d,))
    fi

    # Check we don't already have an output file of that name. If so, append with
    # a number.
    if [ -e ./formatted/${listOfSites[s]}.txt ]; then
        numFiles="_$(ls ./formatted/${listOfSites[s]}*.txt | wc -l)"
    else
        numFiles=""
    fi

    echo -n "" > ./formatted/${listOfSites[s]}${numFiles}.txt
    for file in ${listOfFiles[@]}; do
        echo $file ${listOfSites[s]}${numFiles}
        cat ./cleaned/${file}.txt >> ./formatted/${listOfSites[s]}${numFiles}.txt
    done
done

