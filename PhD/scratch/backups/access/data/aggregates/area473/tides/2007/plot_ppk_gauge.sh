#!/bin/bash

# script to plot the gauge data and the ppk raw and processed data for checks
# etc.

# format the data
for i in ./raw_data/ppkraw_plot.txt ./raw_data/PPKTides_all.txt \
   ./raw_data/TIDESTAT_formatted.txt ./raw_data/ppkraw.txt; do
      awk '{if ($2 != "" && $1 != ">") print $1"T"$2,$3; else print $1}' $i > ${i%.txt}.awkd
done

ppk_raw_plot=./raw_data/ppkraw_plot.awkd
ppk_raw=./raw_data/ppkraw.awkd
ppk_proc=./raw_data/PPKTides_all.awkd
gauge_raw=./raw_data/TIDESTAT_formatted.awkd

pr_area=-R2007-08-09T21:00:00/2007-08-10T11:00:00/46.2/52.2
pp_area=-R2007-08-09T21:00:00/2007-08-10T11:00:00/1/7
gr_area=-R2007-08-09T21:00:00/2007-08-10T11:00:00/51/57

proj=-JX24cT/15
outfile=./images/ppk_gauge.ps

# make a basemap
psbasemap $pr_area $proj -K -Xc -Yc \
   -Bpa2Hf1Hg2H:"Date":/0weSn -Bsa1D/0 > $outfile

# plot the raw ppk
gmtset INPUT_DATE_FORMAT dd/mm/yyyy
psxy $pr_area $proj -O -K -W0.1/0/100/200 -H1 -M \
   -Bp0/a1:"GPS Height (m) (inner) / Water Depth (m) (outer)":ES $ppk_raw_plot \
   >> $outfile

# plot the processed ppk
gmtset INPUT_DATE_FORMAT dd/mm/yyyy
psxy $pp_area $proj -O -K -W5/100/200/0 -M \
   -B0/a1f0.5g1:"Height (m) CD":WSn $ppk_proc \
   >> $outfile
psxy $pp_area $proj -O -K -W5/100/200/0 -M \
   -B0 $ppk_proc -Sc0.1 >> $outfile

# plot the raw gauge
gmtset INPUT_DATE_FORMAT dd-mm-yy
gmtset ANNOT_OFFSET_SECONDARY 0.5c # 0.2c
psxy $gr_area $proj -O -K -W5/200/0/100 \
   -Bsg2H/a1ESn $gauge_raw \
   >> $outfile
psxy $gr_area $proj -O -K -W5/200/0/100 \
   -B0 $gauge_raw -Sc0.1 >> $outfile

# add the newhaven observed for 2007
# data aren't available yet...

# add a key:

# set up the dimensions
page=-R0/35/0/28
a4=-JX35c/28c

# plot the various labels
psbasemap $page $a4 -O -K -P -B0wesn -X-4 -Y-7.5 >> $outfile
pstext $page $a4 -Bwesn -X1 -Y0 -O -K << TEXT >> $outfile
4 4.9 12 0.0 0 1 Raw Gauge Water Depth
12 4.9 12 0.0 0 1 Raw PPK GPS Height
19 4.9 12 0.0 0 1 PPK GPS and Tide Gauge Tidal Correction
TEXT

# plot the lines for the key
psxy $page $a4 -O -K -W -W5/200/0/100 << RED_LINE >> $outfile
3 5
3.5 5
RED_LINE
psxy $page $a4 -O -K -W -W5/200/0/100 -Sc0.1 << RED_DOT >> $outfile
3.25 5
RED_DOT
psxy $page $a4 -O -K -W -W5/0/100/200 << BLUE_LINE >> $outfile
11 5
11.5 5
BLUE_LINE
psxy $page $a4 -O -K -W -W5/100/200/0 << GREEN_LINE >> $outfile
18 5
18.5 5
GREEN_LINE
psxy $page $a4 -O -W -W5/100/200/0 -Sc0.1 << GREEN_DOT >> $outfile
18.25 5
GREEN_DOT

echo -n "converting $outfile to pdf "
ps2pdf -sPAPERSIZE=a4 -dPDFSETTINGS=/prepress "$outfile" \
   ${outfile%.ps}.pdf
echo -n "and jpeg... "
gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE \
   "-sOutputFile=${outfile%.ps}.jpg" \
   "$outfile" > /dev/null
echo "done."

exit 0
