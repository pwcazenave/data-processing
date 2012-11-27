#!/bin/bash

# script to plot the output of matlab for the pol conference poster

gmtset LABEL_FONT_SIZE=16

area=-R-1/1/-1/1
imgarea=-R-0.5/0.5/-0.5/0.5
proj=-JX15
gres=0.00295857/0.0024

infile=./mca_fft.csv
grdfile=./${infile%.*}.grd
cptfile=./mca_fft.cpt
outfile=./mca_fft.ps

gmtset D_FORMAT=%g
xyz2grd $area -I$gres $infile -G$grdfile
#makecpt -T0/0.3/0.01 -Crainbow -Z > $cptfile
makecpt -T0/500000/1000 -Crainbow -Z > $cptfile

psbasemap $imgarea $proj -B0 -K -Xc -Yc > $outfile
grdimage $imgarea $proj $grdfile -C$cptfile -O -K \
   -Ba0.2g0.2:"kx (m@+-1@+)":/a0.2g0.2:"ky (m@+-1@+)":WeSn >> $outfile
#psscale -D16.5/7.5/7/0.5 -B0.05:"Height (m)": -C$cptfile -O >> $outfile
psscale -D16.5/7.5/7/0.5 -B100000:"Energy (m@+2@+)": -C$cptfile -O >> $outfile

formats(){
   echo -n "converting to pdf "
   ps2pdf -sPAPERSIZE=a4 -dPDFSETTINGS=/prepress -q $1 ${1%.ps}.pdf
   echo -n "and png... "
   gs -sDEVICE=png16m -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q \
      -sOutputFile=${1%.ps}.png $outfile
   echo "done."
}

formats $outfile
