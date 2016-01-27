#!/usr/bin/env bash

# Hacky script (as ever) to extract lon,lat,name for the data from the CCO.

set -eu

metadata=(../metadata/*.xml)
short=()

for ((i=0; i<${#metadata[@]}; i++)); do
    short[i]=$(echo $(basename ${metadata[i]}) | cut -f1 -d_)
done
# Unique list of shortnames.
shortnames=($(tr ' ' '\n' <<< "${short[@]}" | sort -u | tr '\n' ' '))

echo "lonDD,latDD,name,shortname" > ../locations.csv
for i in ${shortnames[@]}; do
    lons=()
    lats=()
    longnames=()
    todo=(../metadata/$i*.xml)
    echo -n "Working on $i... "
    for ((s=0; s<${#todo[@]}; s++)); do
        lon1=$(grep -a westbc ${todo[s]} | cut -f2 -d">" | cut -f1 -d"<")
        lon2=$(grep -a eastbc ${todo[s]} | cut -f2 -d">" | cut -f1 -d"<")
        lat1=$(grep -a northbc ${todo[s]} | cut -f2 -d">" | cut -f1 -d"<")
        lat2=$(grep -a southbc ${todo[s]} | cut -f2 -d">" | cut -f1 -d"<")
        if [[ $(echo $lon2 | tr -d "/") == NA ]]; then
            lon2=$lon1
        fi
        if [[ $(echo $lat2 | tr -d "/") == NA ]]; then
            lat2=$lat1
        fi
        lons[s]=$(echo "scale=6; ($lon2 + $lon1) / 2" | bc -l)
        lats[s]=$(echo "scale=6; ($lat2 + $lat1) / 2" | bc -l)
        longname[s]=\"$(grep -a buoyloc ${todo[s]} | cut -f2 -d">" | cut -f1 -d"<")\"
    done
    # Debugging positions.
    #echo ${lons[@]} | tr " " "\n" > lons_${i}.txt
    #echo ${lats[@]} | tr " " "\n" > lats_${i}.txt
    echo "done."
    # Find the mode of each lat/long pair and use that as the canonical value.
    lon=$(echo ${lons[@]} | tr " " "\n" | awk '{a[$1]++; if (a[$1] > comV) { comN=$1; comV=a[$1]} } END {print comN}')
    lat=$(echo ${lats[@]} | tr " " "\n" | awk '{a[$1]++; if (a[$1] > comV) { comN=$1; comV=a[$1]} } END {print comN}')
    for n in "${longname[@]}"; do
        if [[ "$n" != \"\" ]]; then
            # Strip out quotes
            name="$(echo "$n" | tr -d "\"" | tr " " "_")"
            break
        fi
    done
    echo ${lon},${lat},$name,$i >> ../locations.csv
done

# Braklesham Bay and Hornsea are wrong. Fix those here.
awk -F, '{OFS=","}{if ($3 == "BkB") print $1+1,$2,$3,$4; else print $0}' ../locations.csv | sponge ../locations.csv
awk -F, '{OFS=","}{if ($3 == "Hrn") print $1,$2+3,$3,$4; else print $0}' ../locations.csv | sponge ../locations.csv
