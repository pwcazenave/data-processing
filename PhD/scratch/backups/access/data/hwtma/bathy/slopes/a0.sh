#!/bin/bash

gmtset ANNOT_FONT_SIZE 18
gmtset LABEL_FONT_SIZE 18
gmtset HEADER_FONT_SIZE 22
gmtset ANNOT_FONT_SIZE_SECONDARY 18
gmtset D_FORMAT %7.9lg
gmtset COLOR_NAN 255/255/255

area=-R606924/609044/5618608/5619770
proj=-Jx0.05
outfile=./gradient_a0.ps

psbasemap $area $proj -X7 -Y-50 -K \
   -Ba200f100:Eastings:/a200f100:Northings:WeSn > $outfile
grdimage $area $proj -O -K -Cslope.cpt -Bg200 slope.grd >> $outfile
psscale -D107.5/29/15/1 -B0.1 -Cslope.cpt -O -K >> $outfile
pstext -N $area $proj -O << TEXT >> $outfile
609076 5619370 18 0 0 1 Gradient
TEXT

#gs -sPAPERSIZE=a0 $outfile
ps2pdf -sPAPERSIZE=a0 $outfile
gs -sDEVICE=jpeg -r1200 -sPAPERSIZE=a0 -dBATCH -dNOPAUSE \
   -sOutputFile=./$(basename $outfile .ps).jpg $outfile
