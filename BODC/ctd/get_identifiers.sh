#!/bin/bash

# Get the identifiers for a range of parameters I'm interested in putting into
# the CTD database.

data=('Conversion' 'Practical' 'Temperature' 'Concentration' 'Saturation' 'fluorometer' 'Depth' 'Pressure' 'Downwelling vector' 'Attenuance' 'Sigma-theta' 'Transmittance')

OLDIFS=$IFS
IFS="
"

for var in ${data[@]}; do
    #echo -n "$var = "
    res=($(grep -B1 "$var" raw_data/*.lst | grep -v $var | grep -v -- -- | cut -f2 -d- | grep -v lst | cut -f1 -d' ' | sort -u))

    for ((i=0; i<${#res[@]}; i++)); do

        if [ $i -eq 0 -a ${#res[@]} -ne 1 ]; then
            echo -n "['${res[i]}', "
        elif [ $i -eq 0 -a ${#res[@]} -eq 1 ]; then
            echo -n "['${res[i]}']"
        elif [ $i -eq $((${#res[@]} - 1)) -o ${#res[@]} -eq 1 ]; then
            echo -n "'"${res[i]}"'"]
        else
            echo -n "'"${res[i]}"', "
        fi
    done
    echo
done

IFS=$OLDIFS
