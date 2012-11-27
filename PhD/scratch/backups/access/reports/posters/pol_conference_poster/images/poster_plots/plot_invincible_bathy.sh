#!/bin/bash

# script to plot the output of matlab for the pol conference poster

gmtset LABEL_FONT_SIZE=16

area=-R638275/638380/5622625/5622760
proj=-Jx0.13
gres=0.5

infile=./invincible_detrend.xyz
trans4=./invincible_trans4.xy
trans5=./invincible_trans5.xy
grdfile=./grids/${infile%.*}.grd
gradfile=./grids/${infile%.*}_grad.grd
cptfile=./invincible.cpt
outfile=./images/invincible.ps

gmtset D_FORMAT=%g
#xyz2grd $area -I$gres $infile -G$grdfile
#grdgradient -Nt0.7 -A290 $grdfile -G$gradfile
makecpt -T-0.8/0.8/0.01 -Cwysiwyg -Z > $cptfile

gmtset D_FORMAT=%.0f
psbasemap $area $proj -B0 -K -Xc -Yc -P > $outfile
grdimage $area $proj $grdfile -I$gradfile -C$cptfile -O -K \
   -Ba20g10:"Eastings":/a20g10:"Northings":WeSn >> $outfile
gmtset D_FORMAT=%g
psscale -D6.9/-2.2/5/0.5h -B0.4:"Depth (m)": -C$cptfile -O -K >> $outfile

psxy $area $proj $trans4 -W8/150/0/50 -O -K >> $outfile
psxy $area $proj $trans5 -W8/50/0/150 -O -K >> $outfile

pstext $area $proj -N -O -K -D0.3/0.3 -WwhiteO0,white << TRANS4 >> $outfile
$(head -n1 $trans4) 16 0 0 1 A
TRANS4
pstext $area $proj -N -O -K -D-0.3/0.6 -WwhiteO0,white << TRANS4 >> $outfile
$(tail -n1 $trans4) 16 0 0 1 A'
TRANS4
pstext $area $proj -N -O -K -D0.3/-1.2 -WwhiteO0,white << TRANS5 >> $outfile
$(head -n1 $trans5) 16 0 0 1 B
TRANS5
pstext $area $proj -N -O -D-0.3/-0.9 -WwhiteO0,white << TRANS5 >> $outfile
$(tail -n1 $trans5) 16 0 0 1 B'
TRANS5

formats(){
   echo -n "converting to pdf "
   ps2pdf -sPAPERSIZE=a4 -dPDFSETTINGS=/prepress -q $1 ${1%.ps}.pdf
   echo -n "and jpeg... "
   gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q \
      -sOutputFile=${1%.ps}.jpg $outfile
   echo "done."
}

formats $outfile
