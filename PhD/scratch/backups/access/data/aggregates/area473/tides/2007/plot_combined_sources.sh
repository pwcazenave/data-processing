#!/bin/bash

# script to plot the following:
#
#  1. combined ppk and gauge data (with offset of 4.8m adjusted for)
#  2. trendline of that new dataset
#

#set -x
set -e

gmtset INPUT_DATE_FORMAT dd/mm/yyyy
gmtset OUTPUT_DATE_FORMAT dd/mm/yyyy
gmtset D_FORMAT %g

area=-R2007-08-09T21:00:00/2007-08-10T11:00:00/45.2/53.2
proj=-JX24cT/14

outfile=./images/combined_trend.ps

# add the ppk data to the tidal data from the gauge (ppk_padding) to make
# a new trend line
#awk '{print $1,$2-4.8}' ./raw_data/ppkraw_padding.txt \
#   > ./raw_data/ppkraw_padding_minus4.8.txt
cat ./raw_data/ppkraw.awkd ./raw_data/ppkraw_padding_high_res.txt | \
   sort | grep -v E > ./raw_data/ppk_gauge_composite.awkd

# make a pseudo tidal curve from the composite file
awk '{print $1,$2-45.2}' ./raw_data/ppk_gauge_composite.awkd | tr "T" " " > \
   ./raw_data/ppk_composite_tide_correction.txt

combined=./raw_data/ppk_gauge_composite.awkd

# make a basemap
psbasemap $area $proj -K -Xc -Yc \
   -Bpa2Hf1Hg2H:"Date":/0:."Raw PPK GPS height and tide gauge water depth for the 2007 survey":weSn -Bsa1D/0 > $outfile

# plot the combined data
psxy $area $proj -O -K -W3/0/100/200 -H1 \
   -B0/a1f0.5g1:"Height (m) blue/grey":WSn $combined >> $outfile

# make a trend line for that data and plot
trend1d -Fxm -fT -N300f $combined > ${combined%.awkd}.trend
psxy $area $proj -O -K -W1/128/128/128 -B0 ${combined%.awkd}.trend >> $outfile

# unformat the trend line and remove the offset
awk '{print $1,$2-45.2}' ${combined%.awkd}.trend | tr "T" " " \
   > ${combined%.awkd}.txt

# add in the tide correction from emu (ppk derived)
pp_area=-R2007-08-09T21:00:00/2007-08-10T11:00:00/0/8

psxy $pp_area $proj -O -W3/100/200/0 -Bp0/a1f0.5g1:"PPK Tidal Height (m) green":E \
   ./raw_data/PPKTides_all.awkd >> $outfile

#psxy $pp_area $proj -O -W3/0/0/0 -Bp0/a1f0.5g1:"PPK Tidal Height (m) green":E \
#   ./raw_data/ppk_composite_tide_correction.txt >> $outfile

echo -n "convert the image to pdf... "
ps2pdf -dPDFSETTINGS=/prepress -sPAPERSIZE=a4 "$outfile" "${outfile%.ps}.pdf" \
   &> /dev/null
echo -n "and jpeg... "
gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE \
   "-sOutputFile=${outfile%.ps}.jpg" \
   "$outfile" &> /dev/null
echo "done."

exit 0
