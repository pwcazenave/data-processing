#!/bin/bash

gmtset ANNOT_FONT_SIZE 18
gmtset LABEL_FONT_SIZE 18
gmtset HEADER_FONT_SIZE 22
gmtset ANNOT_FONT_SIZE_SECONDARY 18
gmtset D_FORMAT %7.9lg
gmtset COLOR_NAN 255/255/255

area=-R606924/609044/5618608/5619770
proj=-Jx0.05
outfile=./images/bouldnor_cliff_a0.ps

psbasemap $area $proj -X7 -Y-50 -K \
   -Ba200f100:"Eastings":/a200f100:"Northings"::."Bouldnor Cliff Bathymetry":WeSn \
   > $outfile
grdimage $area $proj -O -K -C.all_bathy.cpt -Bg200 all_bathy_final.grd >> $outfile
psscale -D107.5/29/15/1 -B2 -C.all_bathy.cpt -O -K >> $outfile
pstext -N $area $proj -O << TEXT >> $outfile
609076 5619370 18 0 0 1 Depth (m)
TEXT

#gs -sDEVICE=x11 -sPAPERSIZE=a0 $outfile
ps2pdf -sPAPERSIZE=a0 $outfile ./images/$(basename $outfile .ps).pdf
gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a0 -dBATCH -dNOPAUSE \
   -sOutputFile=./images/$(basename $outfile .ps).jpg $outfile
