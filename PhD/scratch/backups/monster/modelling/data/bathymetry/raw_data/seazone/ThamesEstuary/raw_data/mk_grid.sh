#!/bin/bash

# script to make a "x" metre resolution grid of the seazone data

set -e

gmtset D_FORMAT=%g LABEL_FONT_SIZE=16

area=-R-16/13/43.5/63
#area=-R1.25/1.75/50.9/51.4 # extent of the seazone subset anyway
proj=-JM15
gres=2000e # match the cd2msl grid resolution

#infile=./subset_larger.xyz
infile=./bathy.xyz
cpt=./seazone.cpt
outfile=./images/seazone_subset_larger_${gres/e/m}.ps

mkregular(){
   echo "blockmean and xyz2grd... "
   gmtset D_FORMAT=%.6f
   blockmean $area -I$gres $infile -V | \
      xyz2grd $area -I$gres -G${infile%.*}_${gres/e/m}_surface.grd
   echo "done."
   gmtset D_FORMAT=%g
}

mkmask(){
   echo -n "make a mask... "
   grdmask $area $infile -I$gres -NNaN/1/1 -S0.2k \
      -G${infile%.*}_${gres/e/m}_mask.grd
   echo "done."
}

mkgrid(){
   echo -n "clip the grid... "
   grdmath ${infile%.*}_${gres/e/m}_surface.grd ${infile%.*}_${gres/e/m}_mask.grd MUL = ${infile%.*}_${gres/e/m}.grd
   echo "done."
}

applygrid(){
   echo -n "correct the seazone data... "
   grdmath ${infile%.*}_${gres/e/m}.grd ../cd2msl/grids/uk_csm_v3_${gres/e/m}_masked.grd SUB = \
      ${infile%.*}_${gres/e/m}_cd2msl_corrected.grd
   echo "done."
}

extractdata(){
   echo -n "extract the xyz... "
   gmtset D_FORMAT=%.6f
   grd2xyz -S ${infile%.*}_${gres/e/m}_cd2msl_corrected.grd \
      > ${infile%.*}_${gres/e/m}_cd2msl_corrected.xyz
   gmtset D_FORMAT=%g
   echo "done."
}

mkcpt(){
   echo -n "make a colour palette... "
   makecpt -Cwysiwyg -T-60/0/0.1 -Z > $cpt
   echo "done."
}

mkplot(){
   echo -n "make a pretty picture... "
#   psbasemap $area $proj -Ba5f2.5 -Xc -Yc -P -K > $outfile
   grdimage $area $proj -Ba5f2.5 -Xc -Yc -P -K -C$cpt \
      ${infile%.*}_${gres/e/m}_cd2msl_corrected.grd > $outfile
   pscoast $area $proj -A1000 -Df -Gblack -N1 -O -K >> $outfile
   psscale -D7.6/-2/7/0.5h -Ba10f5:"Depth (m)": -O -C$cpt >> $outfile
   echo "done."
}

formats(){
   echo -n "converting to pdf "
   ps2pdf -sPAPERSIZE=a4 -dPDFSETTINGS=/prepress -r300 -q $1 \
      ${1%.ps}.pdf
   echo -n "and jpeg... "
   gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q \
      -sOutputFile=${1%.ps}.jpg $1
   echo "done."
}

mkregular
mkmask
mkgrid
applygrid
extractdata
mkcpt
mkplot
formats $outfile

exit 0
