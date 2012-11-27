#!/bin/bash

# script to sort out the formatting of the UKHO offshore tidal data

infile=./north_foreland_offshore_tides_jul-aug-2004.txt
outfile=${infile%.*}_formatted.txt

timesMorn=($(seq 0 100 1100))
timesAfte=($(seq 1200 100 2300))

do_formatting(){
   rm $outfile; touch $outfile
   while read line; do
      lineArr=($(echo $line | cut -f2- -d" "))
      dateJulian=$(echo $line | cut -f1 -d" ")
      day=${line:0:3}
      year=${line:3:2}
      if [ $(($dateJulian % 2)) -eq 0 ]; then
         for ((i=0; i<${#lineArr[@]}; i++)); do
            echo $year $day $(echo "scale=5; ${timesAfte[$i]}/2400" | bc -l) \
               ${timesAfte[$i]} ${lineArr[$i]} >> $outfile
         done
      else
         for ((i=0; i<${#lineArr[@]}; i++)); do
            echo $year $day $(echo "scale=5; ${timesMorn[$i]}/2400" | bc -l) \
               ${timesMorn[$i]} ${lineArr[$i]} >> $outfile
         done
      fi
   done < $infile
}

#do_formatting

# fix up the formatting
awk '{printf "20%02i %3.5f %03i %04i %2.2f\n", $1,$2+$3,$2,$4,$5/100}' $outfile \
   > ${outfile%.*}_awked.txt
#rm /tmp/deleteme
