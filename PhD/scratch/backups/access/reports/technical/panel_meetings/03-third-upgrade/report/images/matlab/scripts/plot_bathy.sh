#!/bin/bash

# script to plot the output of matlab for the pol conference poster

gmtset LABEL_FONT_SIZE=22 ANNOT_FONT_SIZE=20
gmtset D_FORMAT=%g

infile=../"$1"_bathy.csv
trans=../"$1"_profile.csv
area=$(minmax -I1 $infile)
if [ $1 == "invincible" -o $1 == "dutch" ]; then
   proj=-Jx0.1
   int=50
   int2=$(echo "scale=0; $int/2" | bc -l)
elif
   [ $1 == "hsb" ]; then
   proj=-Jx0.07
   int=50
   int2=$(echo "scale=0; $int/2" | bc -l)
else
   proj=-Jx0.04
   int=100
   int2=$(echo "scale=0; $int/2" | bc -l)
fi
gres=$2

grdfile=./grids/$(basename ${infile%.*}.grd)
gradfile=./grids/$(basename ${infile%.*}_grad.grd)
cptfile=./cpts/$(basename ${infile%.*}.cpt)
outfile=./images/$(basename ${infile%.*}.ps)

gmtset D_FORMAT=%.2f
xyz2grd $area -I$gres $infile -G$grdfile
grdgradient -Nt0.7 -A250 $grdfile -G$gradfile
makecpt -T$(cut -f3 -d, $infile | minmax -C | awk '{print $1"/"$2}')/0.01 -Cgray -Z -I > $cptfile

gmtset D_FORMAT=%.0f
psbasemap $area $proj -B0 -K -Xc -Yc > $outfile
grdimage $area $proj $grdfile -I$gradfile -C$cptfile -O -K \
   -Ba${int}g${int2}:"Eastings":/a${int}g${int2}:"Northings":WeSn >> $outfile
gmtset D_FORMAT=%g
psscale -D17/4/-7/0.5 -I -B$3:"Depth (m)": -C$cptfile -O -K >> $outfile

# add in transect lines
psxy $area $proj $trans -W8/black -O -K >> $outfile
pstext $area $proj -N -O -K -D0.3/0.6 -WwhiteO0,white << TRANS >> $outfile
$(awk -F, '{print $1,$2}' $trans | head -n1) 20 0 0 1 L
TRANS
pstext $area $proj -N -O -D-0.5/0.3 -WwhiteO0,white << TRANS >> $outfile
$(awk -F, '{print $1,$2}' $trans | tail -n1) 20 0 0 1 L'
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
