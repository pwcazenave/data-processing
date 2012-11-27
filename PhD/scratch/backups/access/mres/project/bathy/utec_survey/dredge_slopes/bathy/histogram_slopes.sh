#!/bin/bash

# script to plot the result of the slope angle calculation for a transect across
# the dredging zone at Hastings Shingle Bank.

set -e

gmtset D_FORMAT %6.2f

h_area=-R0/90/0/20
h_proj=-JX12/10
p_area=-R580000/583500/95000/97500
p_proj=-Jx0.004
infile=./slope.xy
profile=./raw_data/profile.trk
outfile=./images/slope_histogram.ps

echo -n "apply modulus to input data and plot... "
awk '{print sqrt($1^2), sqrt($2^2)}' $infile | \
   pshistogram $h_area $h_proj \
   -Ba20f10g20:"Slope Angle (@+o@+)":/a5f2.5g5:,%::."Slope Angle from dredge channels at Hastings Shingle Bank":WeSn \
   -G200/0/100 -L1/0/0/0 -T1 -H2 -P -W1 -Xc -Y17 -Z1 -K > $outfile
echo "done."

echo -n "plot bathy... "
grdimage $p_area $p_proj -Cutec.cpt -O -K -X-0.75 -Y-14 \
   -Ba1000f500g1000:"Eastings":/a1000f500g1000:"Northings"::."Profile location":WeSn \
   -I./grad_resampled_2m.grd ./final_resampled_2m.grd >> $outfile
echo -n "add the profile location... "
awk '{print $1, $2}' $profile | \
   psxy $p_area $p_proj -H1 -W2/0/0/0 -O >> $outfile
echo "done."

echo -n "conversion... "
gs -sDEVICE=jpeg -r1200 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE \
   -sOutputFile=./images/$(basename "$outfile" .ps).jpg "$outfile" > /dev/null
ps2pdf -sPAPERSIZE=a4 $outfile ./images/$(basename "$outfile" .ps).pdf \
   > /dev/null
echo "done."

gs -sPAPERSIZE=a4 $outfile > /dev/null

gmtset D_FORMAT %g

exit 0
