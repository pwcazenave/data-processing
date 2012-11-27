#!/bin/bash

# script to make a grid of a triangulated data set

gmtset D_FORMAT=%g LABEL_FONT_SIZE=16

area=-R-16/13/43.5/63
#area=-R1.25/1.75/50.9/51.4
proj=-JM15
#gres=200e # make it 200m - about the finest I'll need for the Goodwin Sands
gres=2000e # make it 1km - about as find as will be needed for Hastings Shingle Bank.

infile=./raw_data/cd2msl.xyz # interpolated data from MIKE21 mesh
tidefile=./raw_data/MSL.xyz # MSL positions and values from MIKE-CMAP
gridfile=./grids/uk_csm_v3_${gres%e}m.grd
cpt=./cd2msl.cpt
outfile=./images/cd2msl_plot_${gres%e}m.ps # include resolution in image name

mktri(){
   echo -n "triangulating... "
   triangulate $area $proj -I$gres -G${gridfile%.grd}_interp.grd $infile \
      > /dev/null 
   echo "done."
}

mkland(){
   echo -n "make land mask... "
   grdlandmask $area -I$gres -G${gridfile%.grd}_landmask.grd -A1000 -Df -N1/NaN
   echo "done."
}

mkgrid(){
   echo -n "make a clipped grid... "
   grdmath ${gridfile%.grd}_interp.grd ${gridfile%.grd}_landmask.grd MUL \
      = ${gridfile%.grd}_masked.grd
   echo "done."
}

mkcpt(){
   echo -n "make a colour palette... "
   makecpt -Cwysiwyg -T0/8/0.1 -Z > $cpt
   echo "done."
}

mkplot(){
   echo -n "make a pretty picutre... "
   gmtset D_FORMAT=%.0f
#   psbasemap $area $proj -Ba5f2.5/a5f2.5 -Xc -Yc -P -K > $outfile
   grdimage $area $proj -Ba5f2.5/a5f2.5 ${gridfile%.grd}_masked.grd -C$cpt \
      -Xc -Yc -P -K > $outfile
   pscoast $area $proj -A1000 -Df -Gblack -N1 -W -O -K >> $outfile
   # add the locations
   psxy $area $proj -Sc0.1 -Gwhite $tidefile -O -K >> $outfile
   psscale -D7.5/-2/7/0.5h -Ba1f0.5:"CD to MSL correction (m)": -C$cpt \
      -O >> $outfile
   gmtset D_FORMAT=%g
   echo "done."
}

formats(){
   echo -n "converting to pdf "
   ps2pdf -sPAPERSIZE=a4 -dPDFSETTINGS=/prepress -q $1 \
      ${1%.ps}.pdf
   echo -n "and jpeg... "
   gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q \
      -sOutputFile=${1%.ps}.jpg $1
   echo "done."
}

mktri
mkland
mkgrid
mkcpt
mkplot
formats $outfile

exit 0
