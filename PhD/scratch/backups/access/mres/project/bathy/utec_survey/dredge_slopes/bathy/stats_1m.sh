#!/bin/bash

# script to determine the ideal bathymetric resolution of a given input file

set -e

# global variables
input=./raw_data/raw_bathy.txt
histogram=./images/stats_histogram_1m.ps
image=./images/stats_1m.ps
h_area=-R0/20/0/100
proj=-Jx0.002
h_proj=-JX21/13
proj_text=-JX23/30
area_text=-R0/23/0/30
gres=-I1
gmtset D_FORMAT %6.2f

# formatting etc
gmtset ANNOT_FONT_SIZE 14
gmtset LABEL_FONT_SIZE 14
gmtset HEADER_FONT_SIZE 16
gmtset ANNOT_FONT_SIZE_SECONDARY 14

# inputs
stats_grid=./stats_1m.grd
xyzstat=./raw_data/xyzstat_1m.txt
area=-R578106/588291/91503/98688

#echo -n "calculate bins... "
#xyz2grd $area $gres $input -An -G$stats_grid
#echo "done."

#echo -n "imaging... "
#grd2cpt $area $stats_grid -Cwysiwyg -Z > .1m_stats.cpt
#gmtset D_FORMAT %6.0f
#psbasemap $area $proj -B0 -K -Xc -Yc > $image
#grdimage $area $proj $stats_grid -C.1m_stats.cpt -O -K \
#   -Ba1000f500g1000:"Eastings":/a1000f500g1000:"Northings":WeSn >> $image
#psscale -D21/6.5/5/0.5 -B5 -C.1m_stats.cpt -O -K >> $image
#pstext $proj_text $area_text -O << TEXT >> $image
#21 9.5 14 0.0 0 1 Soundings
#TEXT
#echo "done."

echo -n "convert bin grid to ascii... "
grd2xyz $area $stats_grid -S > $xyzstat
echo "done."

gmtset D_FORMAT %6.0f

echo -n "imaging... "
pshistogram $h_area $h_proj $xyzstat \
   -Ba2f1g2:"Number of raw data points per bin":/a2f1g2:,%:WeSn \
   -G200/0/100 -T2 -W1 -Xc -Yc -Z1 -Q > "$histogram"

# conversion etc...
echo -n "conversion... "
ps2pdf -sPAPERSIZE=a4 $histogram ./images/$(basename $histogram .ps).pdf
#ps2pdf -sPAPERSIZE=a4 $image ./images/$(basename $image .ps).pdf
gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE \
   -sOutputFile=./images/$(basename $histogram .ps).jpg $histogram \
   > /dev/null
#gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE \
#   -sOutputFile=./images/$(basename $image .ps).jpg $image > /dev/null
echo "done."
gmtset D_FORMAT %g

exit 0
