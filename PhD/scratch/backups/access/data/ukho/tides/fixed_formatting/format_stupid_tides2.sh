#!/bin/bash

# script to sort out the formatting of the UKHO offshore tidal data

infile=./fisherman\'s_gat_jun-jul-2005.txt
outfile=${infile%.*}_formatted.csv

timesDay=($(seq 0 100 2300))

do_formatting(){
   rm $outfile; touch $outfile
   while read line; do
      lineArr=($(echo $line | cut -f3- -d" "))
      day=$(echo $line | cut -f2 -d" ")
      year=2005
      month=${line:0:1}
      for ((i=0; i<${#lineArr[@]}; i++)); do
         if [ $day -le "11" ] && [ $month -eq "6" ] && [ ${timesDay[$i]} -lt "800" ]; then
            :
         else
            if [ ${timesDay[$i]} -lt 1000 ]; then
               echo $year,$month,$day,${timesDay[$i]:0:1},00,00,${lineArr[$i]} \
                  >> $outfile
            else
               echo $year,$month,$day,${timesDay[$i]:0:2},00,00,${lineArr[$i]} \
                  >> $outfile
            fi
         fi
      done
   done < $infile
}

do_formatting

# fix up the formatting
awk -F"," '{printf "%04i,%02i,%02i,%02i,%02i,%02i,%2.4f\n", $1,$2,$3,$4,$5,$6,$7}' $outfile \
   > ${outfile%.*}_awked.csv
