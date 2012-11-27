#!/bin/bash

# Script to extract locations from the headers
cd headers
grep -E "mW|mE" *.lst | \
    awk '{print $1}' | \
    tr ":md" " " | \
    sed 's/N//g;s/\.lst//g' | \
    awk '{OFS=","; if ($NF=="W") print $1,$2+($3/60),0-($4+($5/60)); else print $1,$2+($3/60),$4+($5/60)}' \
    > ../wave_locations.csv
cd -
