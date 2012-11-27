#!/bin/bash

# second attempt at a cumulative histogram

infile=./text_output/m20-45_rms_offshore_tides.csv

cut -f1 -d, $infile | awk 'NR>1' | sort -n | \
   awk 'NF>0 {counts[$0] = counts[$0]+1;} END {for (word in counts) print word, counts[word];}'
#   awk -v num=2 '{
#   acc += $1 
#   printf "%6.2f%%\t %6.2f%%\t %3d\n", ($1/num)*100,(acc/num)*100,$2
#   }'

