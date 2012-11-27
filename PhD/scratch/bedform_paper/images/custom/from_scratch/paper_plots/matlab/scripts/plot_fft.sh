#!/bin/bash

# script to plot the output of matlab for the pol conference poster

gmtset LABEL_FONT_SIZE=22 ANNOT_FONT_SIZE=20
gmtset D_FORMAT=%g

infile=../$1_fft.csv
grdfile=./grids/$(basename $infile .csv).grd
cptfile=./cpts/${1}_fft.cpt
outfile=./images/${1}_fft.ps

area=$(minmax -I1 $infile)
#-R-1/1/-1/1
imgarea=-R-0.3/0.3/-0.3/0.3
proj=-JX15
gres=$(minmax -C ../${1}_bathy.csv | awk '{printf "%.4f", 1/($2-$1)}')/$(minmax -C ../${1}_bathy.csv | awk '{printf "%.4f", 1/($4-$3)}')

gmtset D_FORMAT=%g
xyz2grd $area -I$gres $infile -G$grdfile
#makecpt -T0/0.3/0.01 -Crainbow -Z > $cptfile
makecpt -T$(cut -f3 -d, $infile | minmax -C | cut -f2 | awk '{print $1*-0.1}')/$(cut -f3 -d, $infile | minmax -C | cut -f2)/$(cut -f3 -d, $infile | minmax -C | cut -f2 | awk '{print ($1/100)*0.9'})  -Cgray -I -Z > $cptfile

psbasemap $imgarea $proj -B0 -K -Xc -Yc > $outfile
grdimage $imgarea $proj $grdfile -C$cptfile -O -K \
   -Ba0.1g0.1:"kx (m@+-1@+)":/a0.1g0.1:"ky (m@+-1@+)":WeSn >> $outfile
#psscale -D16.5/7.5/7/0.5 -B0.05:"Height (m)": -C$cptfile -O >> $outfile
#psscale -D16.5/7.5/7/0.5 -B$(printf "%000.f" $(cut -f3 -d, $infile | minmax -C | cut -f2 | awk '{print $1/1000'})):"Power": -C$cptfile -O >> $outfile
psscale -D16.5/7.5/7/0.5 -B${2}:"Power": -C$cptfile -O >> $outfile

formats(){
   echo -n "converting to pdf "
   ps2pdf -sPAPERSIZE=a4 -dPDFSETTINGS=/prepress -q $1 ${outfile%.*}.pdf
   echo -n "and png... "
   gs -sDEVICE=png16m -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q \
      -sOutputFile=${1%.ps}.png $outfile
   echo "done."
}

formats $outfile
