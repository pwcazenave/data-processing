#!/bin/bash

# script to plot the explanatory fft figures for the paper

gmtset ANNOT_FONT_SIZE=18 LABEL_FONT_SIZE=18

area=-R0/200/0/200
proj=-JX16

gres=0.5

infile=./synthetic_flat_bathy_input.txt
outfile=./synthetic_flat_input.ps

formats(){
   echo -n "converting to pdf "
   ps2pdf -sPAPERSIZE=a4 -dPDFSETTINGS=/prepress -q $1 \
      ${1%.ps}.pdf
   echo -n "and jpeg... "
   gs -sDEVICE=png16m -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q \
      -sOutputFile=${1%.ps}.png $1
   echo "done."
}

mkgrid(){
   echo -n "make the 2d fft grid... "
   xyz2grd -I0.5 $area $infile -G${infile%.*}.grd
   echo "done."
}

plot(){
   echo -n "make the plot... "
   makecpt -T-3/3/0.1 -Cgray -Z > ./synthetic_bathy.cpt
   grdimage $area $proj -Xc -Yc -K \
      -Ba20f10g100:"Metres East":/a20f10g100:"Metres North":WeSn \
      ./${infile%.*}.grd -C./synthetic_bathy.cpt \
      > $outfile
   psscale -D17/8/7/0.5 -C./synthetic_bathy.cpt -Ba1f0.2:"Depth (m)": -O -K \
      >> $outfile
#   pstext $area $proj -N -O << POWER >> $out2d
#   0.25 0.11 18 0 0 1 Depth (m)
#POWER
   echo "done."
}

mkgrid
plot
formats $outfile

exit 0
