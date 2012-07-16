#!/bin/bash

# Take the files in raw_data and spit out formatted as:
#
#   yyyy mm dd hh mm ss zz rr
#
#  (zz = tidal heigt, rr = residual)

for file in raw_data/*.txt; do
    # Fix the data quality flags to be a new column too. Do so on the last ones
    # only.
    awk '{if (NR>11) print $2,$3,$4,$5}' $file | \
        tr "/:" " " | \
        sed 's/M$/\ M/g;s/N$/\ N/g;s/T$/\ T/g' | \
        sed 's/M\ /\ /g;s/N\ /\ /g;s/T\ /\ /g' | \
        grep . | \
        awk '{if (NF==8) print $0, "P"; else print $0}' \
        > ./formatted/$(basename $file)
done
    
