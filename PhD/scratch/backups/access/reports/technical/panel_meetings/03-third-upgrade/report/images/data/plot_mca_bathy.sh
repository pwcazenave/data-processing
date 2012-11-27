#!/bin/bash

# script to plot the output of matlab for the pol conference poster

gmtset LABEL_FONT_SIZE=18

area=-R638275/638380/5622625/5622760/
area=-R609507/609844/5621433/5621849
proj=-Jx0.04
gres=1

#infile=./mca_detrend.xyz
infile=./mca_detrend_uncertainty.xyz
trans=./mca_profile.csv
grdfile=./${infile%.*}.grd
gradfile=./${infile%.*}_grad.grd
cptfile=./mca_bathy.cpt
outfile=./mca_bathy_detrend.ps

gmtset D_FORMAT=%.2f
xyz2grd $area -I$gres $infile -G$grdfile
grdgradient -Nt0.7 -A250 $grdfile -G$gradfile
makecpt -T-1.3/1.1/0.01 -Crainbow -Z > $cptfile

gmtset D_FORMAT=%.0f
psbasemap $area $proj -B0 -K -Xc -Yc > $outfile
grdimage $area $proj $grdfile -I$gradfile -C$cptfile -O -K \
   -Ba100g50:"Eastings":/a100g50:"Northings":WeSn >> $outfile
gmtset D_FORMAT=%g
psscale -D15/8/7/0.5 -I -B0.5:"Depth (m)": -C$cptfile -O -K >> $outfile

# add in transect lines
psxy $area $proj $trans -W8/250/0/50 -O -K >> $outfile
#psxy $area $proj $trans5 -W8/50/0/150 -O -K >> $outfile

#pstext $area $proj -N -O -K -D0.3/-0.6 -WwhiteO0,white << TRANS4 >> $outfile
#$(head -n1 $trans4) 16 0 0 1 B
#TRANS4
#pstext $area $proj -N -O -K -D-0.3/-0.8 -WwhiteO0,white << TRANS4 >> $outfile
#$(tail -n1 $trans4) 16 0 0 1 B'
#TRANS4
pstext $area $proj -N -O -K -D0.3/0.6 -WwhiteO0,white << TRANS >> $outfile
$(awk -F, '{print $1,$2}' $trans | head -n1) 16 0 0 1 L
TRANS
pstext $area $proj -N -O -D-0.3/0.3 -WwhiteO0,white << TRANS >> $outfile
$(awk -F, '{print $1,$2}' $trans | tail -n1) 16 0 0 1 L'
TRANS

formats(){
   echo -n "converting to pdf "
   ps2pdf -sPAPERSIZE=a4 -dPDFSETTINGS=/prepress -q $1 ${1%.ps}.pdf
   echo -n "and png... "
   gs -sDEVICE=png16m -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q \
      -sOutputFile=${1%.ps}.png $outfile
   echo "done."
}

formats $outfile
