#!/bin/bash

# grid the height results

gmtdefaults -D > .gmtdefaults4

gmtset LABEL_FONT_SIZE=16 ANNOT_FONT_SIZE=16
gmtset D_FORMAT=%g PAPER_MEDIA=a4
gmtset COLOR_NAN=128/128/128

area=-R578106/588473/91505/98705
parea=-R578106/589473/91505/98705
harea=-R0/1/0/30
warea=-R0/30/0/20
darea=-R0/360/0/10
proj=-Jx0.00215
hproj=-JX3.2/2
gres=-I300

infile=./raw_data/hsb_300m_subset_results_errors_asymm.csv
outfile=./images/$(basename ${infile%.*}_heights_vectors_asymmetry_bedform_surface.ps)

formats(){
   echo -n "converting to pdf "
   ps2pdf -sPAPERSIZE=a4 -dPDFSETTINGS=/prepress -q $1 ${outfile%.*}.pdf
   echo -n "and png... "
   gs -sDEVICE=png16m -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q \
      -sOutputFile=${1%.ps}.png $outfile
   echo "done."
}

awk -F, '{if ($3>2) print $1,$2,$15}' $infile | \
   xyz2grd $parea $gres -F -G./grids/$(basename ${infile%.*}_likelihood.grd)
#makecpt $(grdinfo -T0.1 ./grids/$(basename ${infile%.*}_likelihood.grd)) -Cgray \
makecpt -T0/1/0.01 -Cgray \
   > ./cpts/$(basename ${infile%.*}_likelihood.cpt)

gmtset D_FORMAT=%.0f
psbasemap $parea $proj -Ba2000f500:"Eastings":/a1000f500:"Northings":WeSn \
   -X3.2 -Yc -K > $outfile
grdimage $parea $proj -C./cpts/$(basename ${infile%.*}_likelihood.cpt) \
   ./grids/$(basename ${infile%.*}_likelihood.grd) -O -K >> $outfile
gmtset D_FORMAT=%g
grd2xyz ./grids/$(basename ${infile%.*}_likelihood.grd) | \
   awk '{if ($3=="NaN") print $1,$2}' | \
   psxy $parea $proj -Sx0.9 -O -K >> $outfile
awk -F, '{print $1,$2,$5}' $infile | \
	psmask $parea $proj $gres -F -N -S350 -G128/128/128 -O -K >> $outfile
psmask -C -O -K >> $outfile
gmtset LABEL_FONT_SIZE=14 ANNOT_FONT_SIZE=14
psscale -D22/12.7/5/0.3 -B0.2:"Presence": -C./cpts/$(basename ${infile%.*}_likelihood.cpt) -O >> $outfile

formats $outfile
