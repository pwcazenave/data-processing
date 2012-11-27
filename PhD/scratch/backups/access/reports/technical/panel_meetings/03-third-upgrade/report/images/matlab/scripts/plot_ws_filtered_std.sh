#!/bin/bash

# grid the filtered standard deviation ratios

gmtdefaults -D > .gmtdefaults4

gmtset LABEL_FONT_SIZE=18 ANNOT_FONT_SIZE=18
gmtset D_FORMAT=%g PAPER_MEDIA=a4
gmtset COLOR_NAN=128/128/128

area=-R598201/618927/5613228/5627356
parea=$area
harea=-R0/1/0.001/40
warea=-R0/30/0.001/15
darea=-R0/180/0.001/10
proj=-Jx0.0012
hproj=-JX3.2/2
gres=-I200

infile=../ws_200m_subset_results_std_ratio.csv
maskin=../ws_mask_bathy_50m.xyz
outfile=./images/$(basename ${infile%.*}s.ps)

formats(){
   echo -n "converting to pdf "
   ps2pdf -sPAPERSIZE=a4 -dPDFSETTINGS=/prepress -q $1 ${1%.*}.pdf
   echo -n "and png... "
   gs -sDEVICE=png16m -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q \
      -sOutputFile=${1%.ps}.png $1
   echo "done."
}

awk -F, '{print $1,$2,$4}' $infile | grep -v NaN | \
   xyz2grd $parea $gres -F -G./grids/$(basename ${infile%.*}_std_ratios.grd)
#makecpt $(grdinfo -T0.1 ./grids/$(basename ${infile%.*}_std_ratios.grd)) -Cgray \
makecpt -T0/3/0.01 -Cgray \
   > ./cpts/$(basename ${infile%.*}_std_ratios.cpt)

gmtset D_FORMAT=%.0f
psbasemap $parea $proj -Ba4000f1000:"Eastings":/a2000f1000:"Northings":WeSn \
   -X3.2 -Yc -K > $outfile
grdimage $parea $proj -C./cpts/$(basename ${infile%.*}_std_ratios.cpt) \
   ./grids/$(basename ${infile%.*}_std_ratios.grd) -O -K >> $outfile
gmtset D_FORMAT=%g
grd2xyz ./grids/$(basename ${infile%.*}_std_ratios.grd) | \
   awk '{if ($3=="NaN") print $1,$2}' | \
   psxy $parea $proj -Sx0.9 -O -K >> $outfile
   psmask $parea $proj $maskin $gres -F -N -S350 -G128/128/128 -O -K >> $outfile
psmask -C -O -K >> $outfile
psscale -D0.5/14/5/0.3 -B1:"Standard deviation": -C./cpts/$(basename ${infile%.*}_std_ratios.cpt) -O >> $outfile

formats $outfile
