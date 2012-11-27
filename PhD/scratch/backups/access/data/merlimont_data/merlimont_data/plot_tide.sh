#!/bin/bash

# script to plot the predicted tide for Boulogne for 26th August 1918

gmtset D_FORMAT=%g
gmtset INPUT_DATE_FORMAT dd/mm/yyyy
gmtset PLOT_DATE_FORMAT dd/mm/yyyy
gmtset PLOT_CLOCK_FORMAT hh:mm
gmtset ANNOT_FONT_SIZE 12
gmtset ANNOT_FONT_SIZE_SECONDARY 12
gmtset LABEL_FONT_SIZE 14
#gmtset TIME_FORMAT_PRIMARY full
#gmtset OUTPUT_DATE_FORMAT dd-mm-yyyy
#gmtset PLOT_CLOCK_FORMAT hh:mm
#gmtset PLOT_DATE_FORMAT yyyy-mm-dd

predshom=./raw_data/merlimont_pred_tide_august.txt
outfile=./images/tides_august.ps

g_area=-R1918-08-23T00:00/1918-08-30T00:00/0/10
proj=-JX24cT/15

# format as needed and send the output to psxy
#awk '{print $1"T"$2, $3}' $predshom | \
   psxy $g_area $proj $predshom -H1 -K -W5/0/100/200 -Xc -Yc \
   -Bpa12H/a1f0.25g1:"Tidal Height (m)":WeSn \
   -Bsa1Df1D/0 > $outfile
#awk '{print $1"T"$2, $3}' $predshom | \
   psxy $g_area $proj $predshom -H1 -St0.1 -O -K -W5/0/100/200 >> $outfile

# add a key:

# set up the dimensions
page=-R0/35/0/28
a4=-JX35c/28c

# plot the various labels
psbasemap $page $a4 -O -K -P -B0wesn -X-4 -Y-7.5 >> $outfile
pstext $page $a4 -Bwesn -X1 -Y0 -O -K << TEXT >> $outfile
11 4.9 12 0.0 0 1 Predicted Tidal Height (m)
TEXT
#3 4.9 12 0.0 0 1 WXTide Predicted CD (Hastings)
#18 4.9 12 0.0 0 1 PPK GPS and Tide Gauge Combined CD (Eastbourne)

# plot the lines for the key
#psxy $page $a4 -O -K -W5/200/0/50 << RED_LINE >> $outfile
#2 5
#2.5 5
#RED_LINE
#psxy $page $a4 -O -K -W5/200/0/50 -Sc0.1 << RED_DOT >> $outfile
#2.25 5
#RED_DOT
psxy $page $a4 -O -K -W5/0/100/200 << BLUE_LINE >> $outfile
10 5
10.5 5
BLUE_LINE
psxy $page $a4 -O -K -W5/0/100/200 -St0.1 << BLUE_DOT >> $outfile
10.25 5
BLUE_DOT

#psxy $page $a4 -O -K -W5/0/200/100 << GREEN_LINE >> $outfile
#17 5
#17.5 5
#GREEN_LINE
#psxy $page $a4 -O -W5/0/200/100 -Ss0.1 << GREEN_DOT >> $outfile
#17.25 5
#GREEN_DOT

# make pdfs and jpegs
echo -n "converting $outfile to pdf "
ps2pdf -sPAPERSIZE=a4 "$outfile" "${outfile%.ps}.pdf" > /dev/null
echo -n "and jpeg... "
gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE \
   "-sOutputFile=${outfile%.ps}.jpg" \
   "$outfile" &> /dev/null
echo "done."

exit 0
