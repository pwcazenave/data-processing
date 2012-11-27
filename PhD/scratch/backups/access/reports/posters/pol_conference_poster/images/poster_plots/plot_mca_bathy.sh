#!/bin/bash

# script to plot the output of matlab for the pol conference poster

gmtset LABEL_FONT_SIZE=16

area=-R638275/638380/5622625/5622760/
area=-R609507/609844/5621433/5621849
proj=-Jx0.035
gres=1

infile=./mca_detrend.xyz
trans4=./mca_trans12.xy
trans5=./mca_trans13.xy
grdfile=./grids/${infile%.*}.grd
gradfile=./grids/${infile%.*}_grad.grd
cptfile=./mca.cpt
outfile=./images/mca.ps

gmtset D_FORMAT=%.2f
#xyz2grd $area -I$gres $infile -G$grdfile
#grdgradient -Nt0.7 -A250 $grdfile -G$gradfile
makecpt -T-1.8/1.8/0.01 -Cwysiwyg -Z > $cptfile

gmtset D_FORMAT=%.0f
psbasemap $area $proj -B0 -K -Xc -Yc -P > $outfile
grdimage $area $proj $grdfile -I$gradfile -C$cptfile -O -K \
   -Ba100g50:"Eastings":/a100g50:"Northings":WeSn >> $outfile
gmtset D_FORMAT=%g
psscale -D5.9/-2.2/5/0.5h -I -B0.8:"Depth (m)": -C$cptfile -O -K >> $outfile

psxy $area $proj $trans4 -W8/150/0/50 -O -K >> $outfile
psxy $area $proj $trans5 -W8/50/0/150 -O -K >> $outfile

pstext $area $proj -N -O -K -D0.3/-0.6 -WwhiteO0,white << TRANS4 >> $outfile
$(head -n1 $trans4) 16 0 0 1 B
TRANS4
pstext $area $proj -N -O -K -D-0.3/-0.8 -WwhiteO0,white << TRANS4 >> $outfile
$(tail -n1 $trans4) 16 0 0 1 B'
TRANS4
pstext $area $proj -N -O -K -D0.3/0.6 -WwhiteO0,white << TRANS5 >> $outfile
$(head -n1 $trans5) 16 0 0 1 A
TRANS5
pstext $area $proj -N -O -D-0.3/0.3 -WwhiteO0,white << TRANS5 >> $outfile
$(tail -n1 $trans5) 16 0 0 1 A'
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
