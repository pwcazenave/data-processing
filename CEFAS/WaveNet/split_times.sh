#!/bin/bash

# Split the times into individual columns.

for i in raw_data/*.csv; do
    echo "yyyy,mm,dd,HH,MM,SS,temperature" > formatted/$(basename $i)

    awk -F, '{OFS=","}{if (NR>1) print substr($1, 0, 4), substr($1, 6, 2), substr($1, 9, 2), substr($1, 12, 2), substr($1, 15, 2), substr($1, 18, 2), $2}' $i >> formatted/$(basename $i)

done
