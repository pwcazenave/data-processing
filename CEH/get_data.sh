#!/bin/bash
#
# Script to batch download the CEH river flow data using the CEH river IDs (see
# http://www.ceh.ac.uk/data/nrfa/data/search.html).
#
# The search has to be done in two goes (once for stations east of the
# Greenwich meridian, once for stations west of it. The results from those two
# searches are in ceh_rivers_info.csv.
#
# rivers_IRS_crossref.txt is a file from Karen Amoudry (originally from Laurent
# Amoudry) which gives the POLCOMS river data in the following format:
#
# POLCOMS ID | x | y | CEH ID | River flow weighting factor | River name
#
# Pierre Cazenave (Plymouth Marine Laboratory)


info=rivers_IRS_crossref.txt # adjust $name and $id if using this file
info=stations.csv

echo -n "" > positions.txt

main(){
    # Main logic.
    #
    # Won't overwrite existing files but will extract their positions into the
    # positions.txt file.

    while read line; do
        first=$(echo $line | cut -f1 -d,)
        if [ $first == "No." ]; then
            # Skip the header
            continue
        else
            name=$(echo $line | cut -f2 -d, | tr " " "_" | tr -d "/")
            loc=$(echo $line | cut -f3 -d, | tr " " "-" | tr -d "/")
            id=$(echo $line | cut -f1 -d,)
            downloadable=$(echo $line | cut -f6 -d,)

            # Set downloadable if we're using the POLCOMS info file.
            if [ -z $downloadable ]; then downloadable="Y"; fi

            if [ $downloadable == "Y" ]; then
                echo -n "Getting river $name at $(echo $loc | tr "-" " ") ($id), "

                out="./raw_data/${id}_${name}_${loc}.csv"

                if [ -f "$out" ]; then
                    echo ${id},${name}_${loc},$(\grep Reference $out | cut -f3 -d,) >> positions.txt

                    echo "skipping."

                    continue

                    #num=$(\ls -1 ./raw_data/${name}_${loc}*.csv | wc -l)
                    #out="./raw_data/${name}_${loc}_${num}.csv"
                fi

                echo -n "saving to ${out}... "

                # Start with a content length of 30 and increment by once until it
                # works (set the upper content length limit at 40).
                res=1
                cl=30
                until [ $res -eq 0 -o $cl -eq 40 ]; do
                    get_data $id "$out" $cl

                    if [ -f "$out" ]; then
                        res=0
                    fi
                    #res=$?
                    cl=$(($cl + 1))
                done

                echo "done."

                # Extract the grid reference for this station
                echo ${name}_${loc},$(\grep Reference "$out" | cut -f3 -d,) | \
                    sed 's/,$//g' >> positions.txt

                # Wait a realistic amount of time before trying the next one.
                sleep $(echo "scale=0; ($RANDOM % 10) + 10" | bc -l)
            else
                echo "Skipping river $name ($id) - not downloadable."
            fi
        fi

    done < $info
}

get_data(){
    # Wrapper function around CURL to get the data. Takes three arguments:
    #
    # CEH ID
    # Output file name
    # Content length (defaults to 31)
    #
    # A timeout of 10 seconds is set for the command.

    id=$1
    out=$2
    contentlength=$3

    if [ -z $contentlength ]; then
        contentlength=31
    fi

    curl \
        --silent \
        --header 'Host: www.ceh.ac.uk' \
        --header 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:23.0) Gecko/20100101 Firefox/23.0' \
        --header 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' \
        --header 'Accept-Language: en-gb,en;q=0.5' \
        --header 'DNT: 1' \
        --header "Referer: http://www.ceh.ac.uk/data/nrfa/data/download.html?stn=$id&dt=gdf" \
        --header 'Connection: keep-alive' \
        --header 'Content-Type: application/x-www-form-urlencoded' \
        --header "Content-Length: $contentlength" \
        --max-time 10 \
        -X POST \
        --data-binary "db=nrfa_public&stn=$id&dt=gdf" \
        "http://www.ceh.ac.uk/nrfa/data/tsData/$id/data.csv" \
        -o "$out" -L
}

# Launch the main loop.
main

