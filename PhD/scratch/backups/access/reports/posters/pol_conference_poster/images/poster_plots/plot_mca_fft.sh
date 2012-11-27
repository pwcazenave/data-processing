#!/bin/bash

# script to plot the output of matlab for the pol conference poster

gmtset LABEL_FONT_SIZE=16

area=-R-1/1/-1/1
imgarea=-R-0.5/0.5/-0.5/0.5
proj=-Jx15
gres=0.00295857/0.0024

infile=./mca_fft.xyz
grdfile=./grids/${infile%.*}.grd
cptfile=./mca_fft.cpt
outfile=./images/mca_fft.ps

gmtset D_FORMAT=%g
xyz2grd $area -I$gres $infile -G$grdfile
makecpt -T-0.01/0.3/0.001 -Cwysiwyg -Z > $cptfile

psbasemap $imgarea $proj -B0 -K -Xc -Yc -P > $outfile
grdimage $imgarea $proj $grdfile -C$cptfile -O -K \
   -Ba0.2g0.2:"kx (m@+-1@+)":/a0.2g0.2:"ky (m@+-1@+)":WeSn >> $outfile
psscale -D7.5/-2.2/5/0.5h -B0.1:"Height (m)": -C$cptfile -O >> $outfile

formats(){
   echo -n "converting to pdf "
   ps2pdf -sPAPERSIZE=a4 -dPDFSETTINGS=/prepress -q $1 ${1%.ps}.pdf
   echo -n "and jpeg... "
   gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q \
      -sOutputFile=${1%.ps}.jpg $outfile
   echo "done."
}

formats $outfile
