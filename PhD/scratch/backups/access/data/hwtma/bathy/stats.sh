#!/bin/bash

# script to determine the ideal bathymetric resolution of a given input file

input=./raw_data/all_bathy.txt
stats_grid=./hwtma_stats.grd
xyzstat=./raw_data/xyzstat.txt
h_input=./raw_data/xyzstat.awkd
image=./images/stats_20cm.ps
histogram=./images/histogram_20cm.ps
area=-R606924/609044/5618608/5619770
h_area=-R0/80/0/20
proj=-Jx0.01
h_proj=-JX10
gres=-I0.20

gmtset D_FORMAT %7.9lg

xyz2grd $area $gres $input -An -G$stats_grid

grd2cpt $area $stats_grid -Cwysiwyg -Z > .stats.cpt
grdimage $area $proj $stats_grid -C.stats.cpt -K -Xc -Yc \
   -Ba200f100g200:"Eastings":/a200f100g200:"Northings"::."Input File Density":WeSn \
   > $image
psscale -D22/5.5/5/0.5 -B20 -C.stats.cpt \
   -O >> "$image"

grd2xyz $area $stats_grid -S > $xyzstat
awk '{print $3}' $xyzstat > $h_input

pshistogram $h_area $h_proj $h_input \
   -Ba10f2.5g5:"Number of raw data points per bin":/a5f2.5:,%:WeSn \
   -G0/100/200 -P -W1 -Xc -Yc -Z1 > "$histogram"

ps2pdf -sPAPERSIZE=a4 $histogram ./images/$(basename "$histogram" .ps).pdf
gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE \
   -sOutputFile=./images/$(basename "$histogram" .ps).jpg "$histogram" \
   > /dev/null
ps2pdf -sPAPERSIZE=a4 $image ./images/$(basename "$image" .ps).pdf
gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE \
   -sOutputFile=./images/$(basename "$image" .ps).jpg "$image" > /dev/null
