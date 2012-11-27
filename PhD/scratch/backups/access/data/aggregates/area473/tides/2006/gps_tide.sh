#!/bin/bash

# script to plot the output from the dumprtf program with time against the
# newhaven observed tidal curve.

gmtset INPUT_DATE_FORMAT dd-mm-yyyy
gmtset TIME_FORMAT_PRIMARY full
gmtset OUTPUT_DATE_FORMAT dd-mm-yyyy
gmtset PLOT_CLOCK_FORMAT hh:mm

gmtset ANNOT_FONT_SIZE 12
gmtset LABEL_FONT_SIZE 12
gmtset HEADER_FONT_SIZE 14
gmtset ANNOT_FONT_SIZE_SECONDARY 12

nh_area=-R2006-09-11T06:00/2006-09-12T06:00/-1/9
gps_area=-R2006-09-11T06:00/2006-09-12T06:00/48/58
proj=-JX24cT/13

gps_infile=./raw_data/*.out
nh_infile=./raw_data/NHA0609.txt
hastings=./raw_data/wxtide_hastings_predicted_11-12_sept_2006.txt
outfile=./images/tidal_comparison.ps

preprocess(){
   # gps
   cat $gps_infile > ./raw_data/gps_tide.txt
   # newhaven
   grep \/ $nh_infile | tr "/T" " " | awk '{print $4"-"$3"-"$2"T"$5, $6}' \
      > ${nh_infile%.txt}.gps
}

mktrend(){
   # make a trend line for the gps data
   sort -g ./raw_data/gps_tide.txt | \
   	awk '{if (NR%1==0); if ($2<58) print $1, $2}' | \
   	trend1d -Fxm -fT -N20 > ./raw_data/gps_tide_trend.txt
}

plot(){
   # start the graph
   psbasemap $nh_area $proj -Bpa3Hf1Hg3H:"Date":/a1f0.25g1:"Height (m) CD":WSn \
      -Xc -Yc -Bsa1D/0 -K > $outfile
   psbasemap $gps_area $proj -B0/a1f0.25g1:"Height (m) WGS84":E -Bsa1D/0 -O \
      -K >> $outfile

   # plot the data
   # gps (line = trend, dots = data)
   awk '{if (NR%1==0) print $1, $2}' $gps_infile ./raw_data/gps_tide.txt | \
   	psxy $gps_area $proj -B0 -W3/200/0/50 -O -K -Sc0.1 >> $outfile
   sort -g ./raw_data/gps_tide_trend.txt | \
   	awk '{if (NR%1==0 && $2<58) print $1, $2}' | \
   	psxy $gps_area $proj -B0 -W3/100/0/25 -O -K >> $outfile

   # newhaven observed
   psxy $nh_area $proj -B0 -W3/0/200/50 -O -K ${nh_infile%.txt}.gps >> $outfile
   psxy $nh_area $proj -B0 -W3/0/200/50 -O -K -Sc0.1 ${nh_infile%.txt}.gps \
      >> $outfile

   # my tidal curve created from the trend line - just to make sure it's roughly
   # right relative to the newhaven stuff
   #awk '{if (NR%210==0) print $1"T"$2, $3}' \
   #   ./raw_data/gps_tide_correction_test.txt | \
   #   psxy $nh_area $proj -B0 -W1/0/50/200 -O -K >> $outfile
   #awk '{if (NR%210==0) print $1"T"$2, $3}' \
   #   ./raw_data/gps_tide_correction_test.txt | \
   #   psxy $nh_area $proj -B0 -W1/0/50/200 -O -Sc0.1 >> $outfile

   # add the predicted hastings curve
   psxy $nh_area $proj -B0 -O -K -W3/0/100/200 $hastings >> $outfile
   awk '{if (NR%10==0) print $1, $2}' $hastings | \
      psxy $nh_area $proj -B0 -O -K -W3/0/100/200 -Sc0.1 >> $outfile

   # add a key:

   # set up the dimensions
   page=-R0/35/0/28
   a4=-JX35c/28c

   # plot the various labels
   psbasemap $page $a4 -O -K -P -B0wesn -X-4 -Y-7.5 >> $outfile
   pstext $page $a4 -Bwesn -X1 -Y0 -O -K << TEXT >> $outfile
   5 4.9 12 0.0 0 1 Hastings Predicted Curve
   14 4.9 12 0.0 0 1 RTK GPS Height
   20 4.9 12 0.0 0 1 Newhaven Observed Tidal Curve
TEXT

   # plot the lines for the key
   psxy $page $a4 -O -K -W5/0/100/200 << BLUE_LINE >> $outfile
   4 5
   4.5 5
BLUE_LINE
   psxy $page $a4 -O -K -W5/0/100/200 -Sc0.1 << BLUE_DOT >> $outfile
   4.25 5
BLUE_DOT
   psxy $page $a4 -O -K -W5/100/0/25 << RED_LINE >> $outfile
   13 5
   13.5 5
RED_LINE
   psxy $page $a4 -O -K -W5/200/0/5 -Sc0.1 << RED_DOT >> $outfile
   13.25 5
RED_DOT
   psxy $page $a4 -O -K -W5/0/200/50 << GREEN_LINE >> $outfile
   19 5
   19.5 5
GREEN_LINE
   psxy $page $a4 -O -W5/0/200/50 -Sc0.1 << GREEN_DOT >> $outfile
   19.25 5
GREEN_DOT
}

formats(){
   ps2pdf -sPAPERSIZE=a4 $outfile ${outfile%.ps}.pdf \
      > /dev/null
   gs -sDEVICE=jpeg -sPAPERSIZE=a4 -r300 -dBATCH -dNOPAUSE \
      -sOutputFile=${outfile%.ps}.jpg $outfile > /dev/null
}

#preprocess
#mktrend
plot
formats

exit 0
