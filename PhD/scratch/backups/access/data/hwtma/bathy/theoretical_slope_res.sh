#!/bin/bash

# plot the theoretical maximum angle precision for a number of grid resolutions

area=-R0/10/0/6
proj=-JX21/13
infile=./raw_data/errors.dat
outfile=./images/theoretical_angles.ps

# plot the results
echo -n "plot... "
#psxy $area $proj -Xc -Yc $infile -K -W4/0/50/220 -Ey \ # with error bars
psxy $area $proj -Xc -Yc $infile -K -W4/0/50/220 \
   -Ba1f0.5g1:"Grid Resolution (m)":/a1f0.5g1:"Bed Slope (@+o@+)":WeSn \
   > $outfile
psxy $area $proj $infile -O -Sd0.15 -W4/0/50/220 >> $outfile
echo "done."

# convert, display, and all that
echo -n "convert to: jpeg "
gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE \
   -sOutputFile=./images/$(basename "$outfile" .ps).jpg "$outfile" > /dev/null
echo -n "pdf "
ps2pdf -sPAPERSIZE=a4 $outfile ./images/$(basename "$outfile" .ps).pdf \
   > /dev/null
echo "done."

exit 0
