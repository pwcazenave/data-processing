#!/bin/bash

# Script to extract the wavelength and height measurements from the FFT
# analysis and create a shelf-wide grid at a not too crazy resolution 
# for use in getRoughness.m.

outfile=./raw_data/bedforms.csv
if [ -e $outfile ]; then
    rm -f $outfile
fi


extractGoodData(){
    for i in ./raw_data/[c-zA-Z]*.csv; do 
        awk -F, '{OFS=","; if ($15==1) print $1,$2,$3,$5}' $i >> $outfile
    done
}

extractGoodData
