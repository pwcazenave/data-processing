#!/bin/bash

# Script to get all the downloadable CEH river data. Doesn't work because they
# obviously require you to click "I Agree" on their website. Annoying.

url="http://www.ceh.ac.uk/nrfa/data/tsData/"

for id in $(awk -F, '{if (NR > 1) print $1}' stations_downloadable.csv); do
    wget $url/$id/data.csv -O ./raw_data/$id.csv

    # Sleep for a short while before getting the next one (up to 8 seconds).
    sleep $(echo "scale=0; $RANDOM % 8" | bc -l)
done
