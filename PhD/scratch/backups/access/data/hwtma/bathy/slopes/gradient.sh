#!/bin/bash

# script to plot the slope from NW

area=$(< ../.minmax)
proj=-Jx0.01
infile=./slope.grd
outfile=./gradient.ps

gmtset ANNOT_FONT_SIZE 10
gmtset LABEL_FONT_SIZE 12
gmtset HEADER_FONT_SIZE 14
gmtset ANNOT_FONT_SIZE_SECONDARY 10
gmtset D_FORMAT %7.9lg
gmtset COLOR_NAN 255/255/255

grd2cpt $area $infile -Cwysiwyg -L-0.25/0.25 -Z > $(basename "$infile" .grd).cpt

psbasemap $area $proj \
   -Ba200f100:"Eastings":/a200f100:"Northings"::."Gradient for Bouldnor Cliff":WeSn \
   -Xc -Yc -K > "$outfile"
grdimage $area $proj -Bg200 -C$(basename "$infile" .grd).cpt $infile -O -K \
   >> "$outfile"
psscale -D22/5.5/5/0.5 -B0.1 -C$(basename "$infile" .grd).cpt -O \
   >> "$outfile"

ps2pdf -sPAPERSIZE=a4 $outfile
gs -sDEVICE=jpeg -dNOPAUSE -dBATCH -sPAPERSIZE=a4 -sOutputFile=./$(basename "$outfile" .ps).jpg -r1200 "$outfile" > /dev/null
