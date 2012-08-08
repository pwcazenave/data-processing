#!/bin/bash

# Get the tidal data from REFMAR using their API

stations=($(cut -f1 -d, ./shelf_stations_raw.csv))
longNames=($(cut -f3 -d, ./shelf_stations_raw.csv))

ID=pcazenave
PASS=******* # replace with actual password
NUMSRC=2 # the quality of the data (1=realtime, 2=10minutes, 4=QC'd
STARTDATE=1800-01-01
ENDDATE=2012-08-01

for ((i=0; i<${#stations[@]}; i++)); do
    wget "http://refmar.shom.fr/onivmer/download?id=$ID&pass=$PASS&idstation=${stations[i]}&idsource=$NUMSRC&datedeb=$STARTDATE&datefin=$ENDDATE" -O ./raw_data/${longNames[i]}.txt

    # Check the output isn't a zero byte or 8 line (header only) file
    nl=$(wc -l < ./raw_data/${longNames[i]}.txt)
    if [ $nl -eq 8 ]; then
        rm -v ./raw_data/${longNames[i]}.txt
    fi
    if [ ! -s ./raw_data/${longNames[i]}.txt ]; then
        rm -v ./raw_data/${longNames[i]}.txt
    fi
done
