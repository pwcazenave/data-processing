#!/bin/bash

# script to add the days from the start of 2004 to the tidal data

infile=./north_foreland_offshore_tides_jul-aug-2004_formatted_awked.txt
outfile=./nfot_matlab_format.csv

format_matlab(){
   rm $outfile; touch $outfile
   while read line; do
      yr=$(echo $line | cut -f1 -d" ")
      currDay=$(echo $line | cut -f3 -d" ")
      currTime=$(echo $line | cut -f4 -d" ")
      currVal=$(echo $line | cut -f5 -d" ")
      newDate=$(date -d "${yr}-01-01 + ${currDay} days" +%y,%m,%d)
      echo 20$newDate,${currTime:0:2},00,00,$currVal >> $outfile
   done < $infile
}

format_matlab

exit 0
