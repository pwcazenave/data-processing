#!/bin/bash

# script to plot the gauge tides from the 2007 area473 emu survey

gmtset D_FORMAT=%g

gmtset INPUT_DATE_FORMAT dd-mm-yy
gmtset TIME_FORMAT_PRIMARY full
gmtset OUTPUT_DATE_FORMAT dd-mm-yyyy
gmtset PLOT_CLOCK_FORMAT hh:mm
gmtset PLOT_DATE_FORMAT yyyy-mm-dd

gauge_in=./raw_data/TIDESTAT.018
#wx_in=./raw_data/wx_tide_output_time_corrected_to_GMT.txt
wx_in_hastings=./raw_data/hastings_predicted_august_2007.txt
#wx_in=./raw_data/wx_tide_output.txt
gps_tide=./raw_data/PPKTides_all.txt
outfile=./images/tides.ps

#g_area=-R2007-08-05T12:00/2007-08-18T01:00/50/57
#wx_area=-R2007-08-05T12:00/2007-08-18T01:00/0/7
g_area=-R2007-08-05T12:00/2007-08-11T00:00/50/57
wx_area=-R2007-08-05T12:00/2007-08-11T00:00/0/7
proj=-JX24cT/15

# format as needed and send the output to psxy
# wxtide data (newhaven)
#awk '{print $1"T"$2, $3}' $wx_in | \
#   psxy $wx_area $proj -K -W5/200/0/50 -Xc -Yc \
#   -Bpa12H/a2f1g2:"Depth (m) CD":WeSn \
#   -Bsa2Df1Dg2D/0 > $outfile
#awk 'FNR>29{print $1"T"$2, $3}' $wx_in | psxy $wx_area $proj -O -K \
#   -W5/200/0/50 -B0 -Sc0.1 >> $outfile
# wxtide data (hastings)
psxy $wx_area $proj -K $wx_in_hastings -W5/200/0/50 -Xc -Yc \
   -Bpa12H/a2f1g2:"Depth (m) CD":WeSn \
   -Bsa2Df1Dg2D/0 > $outfile
psxy $wx_area $proj -O -K $wx_in_hastings -W5/200/0/50 -B0 -Sc0.1 >> $outfile
# gauge data
awk 'FNR>29{if ($3>40 && $3<58) print $1"T"$2, $3}' $gauge_in | \
   psxy $g_area $proj -O -K -W5/0/100/200 \
   -Bpa24H/a2f1g2wESn \
   >> $outfile
awk 'FNR>29{print $1"T"$2, $3}' $gauge_in | psxy $g_area $proj -O -K \
   -W5/0/100/200 -B0 -St0.1 >> $outfile
# add the ppk gps data...
gmtset INPUT_DATE_FORMAT dd/mm/yyyy
awk '{print $1"T"$2, $3}' $gps_tide | psxy $wx_area $proj -O -K \
   -W5/0/200/100 -B0 -M >> $outfile
awk '{print $1"T"$2, $3}' $gps_tide | psxy $wx_area $proj -O -K \
   -W5/0/200/100 -B0 -M -Ss0.1 >> $outfile

# add the appropriate coloured text for the right hand axis
gmtset INPUT_DATE_FORMAT dd-mm-yy
pstext -O -K $g_area $proj -N -G0/100/200 << TEXT >> $outfile
11-08-07T12:00:00 52.35 12 90 0 1 Water Depth (m)
TEXT

# add a key:

# set up the dimensions
page=-R0/35/0/28
a4=-JX35c/28c

# plot the various labels
psbasemap $page $a4 -O -K -P -B0wesn -X-4 -Y-7.5 >> $outfile
pstext $page $a4 -Bwesn -X1 -Y0 -O -K << TEXT >> $outfile
3 4.9 12 0.0 0 1 WXTide Predicted CD (Hastings)
11 4.9 12 0.0 0 1 Tide Gauge Water Depth (m)
18 4.9 12 0.0 0 1 PPK GPS and Tide Gauge Combined CD (Eastbourne)
TEXT

# plot the lines for the key
psxy $page $a4 -O -K -W5/200/0/50 << RED_LINE >> $outfile
2 5
2.5 5
RED_LINE
psxy $page $a4 -O -K -W5/200/0/50 -Sc0.1 << RED_DOT >> $outfile
2.25 5
RED_DOT
psxy $page $a4 -O -K -W5/0/100/200 << BLUE_LINE >> $outfile
10 5
10.5 5
BLUE_LINE
psxy $page $a4 -O -K -W5/0/100/200 -St0.1 << BLUE_DOT >> $outfile
10.25 5
BLUE_DOT
psxy $page $a4 -O -K -W5/0/200/100 << GREEN_LINE >> $outfile
17 5
17.5 5
GREEN_LINE
psxy $page $a4 -O -W5/0/200/100 -Ss0.1 << GREEN_DOT >> $outfile
17.25 5
GREEN_DOT

# make pdfs and jpegs
echo -n "converting $outfile to pdf "
ps2pdf -sPAPERSIZE=a4 "$outfile" "${outfile%.ps}.pdf" > /dev/null
echo -n "and jpeg... "
gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE \
   "-sOutputFile=${outfile%.ps}.jpg" \
   "$outfile" > /dev/null
echo "done."

exit 0
