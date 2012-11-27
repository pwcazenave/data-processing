#!/bin/bash

# Little script to get the appropriate data from the BODC data directory

indir1=../../../../../data/bodc/currents/output/all_sites_formatted/
indir2=../../../../../data/bodc/currents/ftpd/wanted/

set -u

stations=($(awk '{print $2}' ../selected_current_sites.txt))

for ((i=0; i<${#stations[@]}; i++)); do
    echo -n "Working on $(printf 'b%07i' ${stations[i]}).csv... "
    awk -F, '{OFS=","; if (NF==8 || NF==9) print $1,$2,$3,$4,$5,$6,$7,$8}' $indir1/*${stations[i]}.csv > "./raw_data/b$(printf '%07i' ${stations[i]}).csv" \
        || awk -F, '{OFS=","; if (NF==8 || NF==9) print $1,$2,$3,$4,$5,$6,$7,$8}' $indir2/*${stations[i]}.csv > "./raw_data/b$(printf '%07i' ${stations[i]}).csv"
    echo "done."
done
