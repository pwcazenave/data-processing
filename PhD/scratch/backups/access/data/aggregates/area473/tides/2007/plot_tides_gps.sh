#!/bin/bash

# script to plot the tides as output from QINSy.

gps1_area=-R2007-08-09T20:00:00/2007-08-10T13:10/-8/7
gps2_area=-R2007-08-09T20:00:00/2007-08-10T13:10/45/60
proj=-JX23cT/16

infile=./export_gps_2007/gps1_gps2_filtered.txt
wx_in=./raw_data/wx_tide_output.txt
gauge_in=./raw_data/TIDESTAT.018
outfile=./images/gps_tides.ps

# remove lines where gps2 doesn't have any data
# awk '{if ($6 != "") print $0}' ./raw_data/0* > gps1_gps2_filtered.txt

gmtset INPUT_DATE_FORMAT dd/mm/yyyy
gmtset TIME_FORMAT_PRIMARY full
gmtset PLOT_DATE_FORMAT yyyy-mm-dd
gmtset PLOT_CLOCK_FORMAT hh:mm
gmtset D_FORMAT %g
gmtset ANNOT_OFFSET_SECONDARY 0.5c

# plot each gps against time
psbasemap $gps1_area $proj -Bpa2Hf1Hg2H:"Date":/a2f1g1:"Height (m)":Sn -K \
   -Xc -Yc > $outfile
# gps1
awk '{print $1"T"$3,$4}' $infile | psxy $gps1_area $proj -W3/0/5/150 -O -K \
   -Bsa1Df6Hg6H:"Date":/a2f1:"GPS 1 height (blue) and predicted tide (red) (m)":WS -Sc0.01 \
   >> $outfile
# gps2
awk '{print $1"T"$6,$7}' $infile | psxy $gps2_area $proj -W3/50/150/0 -O -K \
   -Bsa1Df6Hg6H:"Date":/a2f1:"GPS 2 height (green) and tidal gauge depth (black) (m)":ES -Sc0.01 >> $outfile

# add the predicted tidal data
gmtset INPUT_DATE_FORMAT dd-mm-yy
awk '{print $1"T"$2, $3}' $wx_in | \
   psxy $gps1_area $proj -O -K -W3/200/0/50 -B0 >> $outfile
awk '{print $1"T"$2, $3}' $wx_in | \
   psxy $gps1_area $proj -O -K -W3/200/0/50 -B0 -Sc0.1 >> $outfile

# and the tidal gauge data
awk 'FNR>29{if ($3>40 && $3<58) print $1"T"$2, $3}' $gauge_in | \
   psxy $gps2_area $proj -O -K -W3/0/0/0 >> $outfile
awk 'FNR>29{if ($3>40 && $3<58) print $1"T"$2, $3}' $gauge_in | \
   psxy $gps2_area $proj -O -W3/0/0/0 -Sc0.1 >> $outfile

# display the image
for image in ./images/gps_tides.ps; do
   echo -n "converting $image to pdf "
   ps2pdf -sPAPERSIZE=a4 "$image" "${image%.ps}.pdf"
   echo -n "and jpeg... "
   gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE \
      "-sOutputFile=${image%.ps}.jpg" \
      "$image" > /dev/null
   echo "done."
done

