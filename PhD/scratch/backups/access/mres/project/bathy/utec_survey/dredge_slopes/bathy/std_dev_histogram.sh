#!/bin/bash

# script to plot the histogram of the standard deviation from the blockmean 
# output

area=-R0/0.5/0/30
proj=-JX15
infile=./raw_data/50cm_bathy_ext.bmd
outfile=./images/std_dev_histogram.ps

# plot the histogram
echo -n "plotting... "
grep -v NaN $infile | pshistogram $area $proj -Xc -Yc -K -T3 -Z1 -P -W0.01 \
   -Ba0.1f0.05:"Standard Deviation":/a5f2.5g5:,%::."Standard Deviation of Processed Depth Values":WeSn \
   -G0/50/200 -L0/0/0 > $outfile
echo "done."

# display and convert
echo -n "convert to: jpeg "
gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE \
   -sOutputFile=./images/$(basename "$outfile" .ps).jpg "$outfile" > /dev/null
echo -n "pdf "
ps2pdf -sPAPERSIZE=a4 $outfile ./images/$(basename "$outfile" .ps).pdf \
   > /dev/null
echo "done."
