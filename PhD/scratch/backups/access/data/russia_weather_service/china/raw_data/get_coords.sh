#!/bin/bash

# Script to get the coordinates from the location file for the sites 
# I have downloaded.


rm ./xy_pos.csv
for i in *.xls; do 
    echo -n "$name," >> ./xy_pos.csv
    name=$(echo $i | cut -f1 -d2 | tr "_" " " | cut -f1 -d" ")
    grep -i "$name" ../../some_locations.csv | cut -f6,10 -d, >> ./xy_pos.csv
done
