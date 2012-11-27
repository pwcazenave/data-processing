#!/bin/bash

# script to plot the output of matlab for the pol conference poster

gmtset LABEL_FONT_SIZE=16

area=-R-1/1/-1/1
imgarea=-R-0.5/0.5/-0.5/0.5
proj=-Jx15
gres=0.01/0.01

infile=./invincible_fft.xyz
#trans4=./invincible_trans4.xy
#trans5=./invincible_trans5.xy
grdfile=./grids/${infile%.*}.grd
#gradfile=./grids/${infile%.*}_grad.grd
cptfile=./invincible_fft.cpt
outfile=./images/invincible_fft.ps

gmtset D_FORMAT=%g
xyz2grd $area -I$gres $infile -G$grdfile
#grdgradient -Nt0.7 -A290 $grdfile -G$gradfile
makecpt -T-0.01/0.12/0.001 -Cwysiwyg -Z > $cptfile

psbasemap $imgarea $proj -B0 -K -Xc -Yc -P > $outfile
grdimage $imgarea $proj $grdfile -C$cptfile -O -K \
   -Ba0.2g0.2:"kx (m@+-1@+)":/a0.2g0.2:"ky (m@+-1@+)":WeSn >> $outfile
psscale -D7.5/-2.2/5/0.5h -B0.05:"Height (m)": -C$cptfile -O >> $outfile

#psxy $area $proj $trans4 -W8/150/0/50 -O -K >> $outfile
#psxy $area $proj $trans5 -W8/50/0/150 -O -K >> $outfile

#pstext $area $proj -N -O -K -D0.3/0.3 -WwhiteO0,white << TRANS4 >> $outfile
#$(head -n1 $trans4) 16 0 0 1 A
#TRANS4
#pstext $area $proj -N -O -K -D-0.3/0.6 -WwhiteO0,white << TRANS4 >> $outfile
#$(tail -n1 $trans4) 16 0 0 1 A'
#TRANS4
#pstext $area $proj -N -O -K -D0.3/-1.2 -WwhiteO0,white << TRANS5 >> $outfile
#$(head -n1 $trans5) 16 0 0 1 B
#TRANS5
#pstext $area $proj -N -O -D-0.3/-0.9 -WwhiteO0,white << TRANS5 >> $outfile
#$(tail -n1 $trans5) 16 0 0 1 B'
#TRANS5

formats(){
   echo -n "converting to pdf "
   ps2pdf -sPAPERSIZE=a4 -dPDFSETTINGS=/prepress -q $1 ${1%.ps}.pdf
   echo -n "and jpeg... "
   gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q \
      -sOutputFile=${1%.ps}.jpg $outfile
   echo "done."
}

formats $outfile
