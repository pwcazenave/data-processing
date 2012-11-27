#!/bin/bash

# script to determine the ideal bathymetric resolution of a given input file

input=./raw_data/all_bathy.txt
stats_grid=./hwtma_stats_20cm.grd
xyzstat=./raw_data/xyzstat_20cm.txt
h_input=./raw_data/xyzstat_20cm.awkd
image=./images/hwtma_stats_20cm.ps
histogram=./images/hwtma_histogram_20cm.ps
area=-R606924/609044/5618608/5619770
h_area=-R0/50/0/30
proj=-Jx0.01
h_proj=-JX21/13
gres=-I0.20

# formatting etc
gmtset ANNOT_FONT_SIZE 14
gmtset LABEL_FONT_SIZE 14
gmtset HEADER_FONT_SIZE 16
gmtset ANNOT_FONT_SIZE_SECONDARY 14

gmtset D_FORMAT %7.9lg

#xyz2grd $area $gres $input -An -G$stats_grid

grd2cpt $area $stats_grid -Cwysiwyg -Z > .stats_20cm.cpt
psbasemap $area $proj -B0 -K -Xc -Yc > $image
grdimage $area $proj $stats_grid -C.stats_20cm.cpt -O -K \
   -Ba200f100g200:"Eastings":/a200f100g200:"Northings":WeSn \
   >> $image
psscale -D22/5.5/5/0.5 -B20 -C.stats_20cm.cpt \
   -O -K >> "$image"
pstext -N $area $proj -O << TEXT >> "$image"
609124 5619500 14 0 0 1 Soundings
TEXT

#grd2xyz $area $stats_grid -S > $xyzstat
awk '{print $3}' $xyzstat > $h_input

pshistogram $h_area $h_proj $h_input \
   -Ba10f2.5g5:"Number of raw data points per bin":/a5f2.5g5:,%:WeSn \
   -G0/100/200 -W1 -Xc -Yc -Z1 > "$histogram"

ps2pdf -sPAPERSIZE=a4 $histogram ./images/$(basename "$histogram" .ps).pdf
gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE \
   -sOutputFile=./images/$(basename "$histogram" .ps).jpg "$histogram" \
   > /dev/null
ps2pdf -sPAPERSIZE=a4 $image ./images/$(basename "$image" .ps).pdf
gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE \
   -sOutputFile=./images/$(basename "$image" .ps).jpg "$image" > /dev/null
