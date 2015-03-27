#!/bin/bash

# Script to extact the positions from the Readme.htm file.

grep h2 ReadMe.htm | cut -f2 -d\> | cut -f1 -d\< | tr -d "/" > sites.txt
echo -n > s.txt
while read line; do
    echo \"$line\" >> s.txt
done < sites.txt
mv s.txt sites.txt

grep 'conditions at' ReadMe.htm | cut -f6,7 -d' ' | sed "s/&deg;/\ /g;s/'//g;s/,//g;s/N/\ N\ 1/g;s/S/\ S\ -1/g;s/W/\ W\ -1/g;s/E/\ E\ 1/g" > positions.txt

paste -d, <(awk '{OFS=","}{print ($1+($2/60))*$4, ($5+($6/60))*$8}' positions.txt) sites.txt >> locs.csv

while read line; do
    if [ -f ./raw_data/$(echo $line | cut -f3 -d, | tr [A-Z] [a-z] | tr -d "\"" | tr " " "-").csv ]; then
        echo "$line" >> exist.csv
    fi
done < locs.csv

echo "latDD,lonDD,name" > locations.csv
cat exist.csv >> locations.csv

rm sites.txt positions.txt locs.csv exist.csv

