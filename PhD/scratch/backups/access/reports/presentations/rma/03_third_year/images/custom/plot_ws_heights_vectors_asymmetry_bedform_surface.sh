#!/bin/bash

# grid the height results

gmtdefaults -D > .gmtdefaults4

gmtset LABEL_FONT_SIZE=18 ANNOT_FONT_SIZE=18
gmtset D_FORMAT=%g PAPER_MEDIA=a4
gmtset COLOR_NAN=128/128/128

area=-R598201/618927/5613228/5627356
parea=$area
harea=-R0/1/0/20
warea=-R0/30/0/10
darea=-R0/360/0/20
proj=-Jx0.0012
hproj=-JX3.2/2
gres=-I200

infile=./raw_data/ws_200m_subset_results_errors_asymm.csv
inbathy=./raw_data/ws_mask_bathy_50m.xyz
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
psbasemap $parea $proj -Ba4000f1000:"Eastings":/a2000f1000:"Northings":WeSn \
   -X4.2 -Yc -K > $outfile
grdimage $parea $proj -C./cpts/$(basename ${infile%.*}_likelihood.cpt) \
   ./grids/$(basename ${infile%.*}_likelihood.grd) -O -K >> $outfile
gmtset D_FORMAT=%g
grd2xyz ./grids/$(basename ${infile%.*}_likelihood.grd) | \
   awk '{if ($3=="NaN") print $1,$2}' | \
   psxy $parea $proj -Sx0.9 -O -K >> $outfile
awk -F, '{print $1,$2,$5}' $inbathy | \
   psmask $parea $proj $gres -F -N -S350 -G128/128/128 -O -K >> $outfile
psmask -C -O -K >> $outfile
# Add in the IOW and Hampshire coastlines
psxy $area $proj -O -K -W5,black -Gwhite -B0 $(pwd)/raw_data/iow_coastline.txt -: >> $outfile
psxy $area $proj -O -K -W5,black -Gwhite -B0 $(pwd)/raw_data/south_coastline.txt >> $outfile
gmtset LABEL_FONT_SIZE=14 ANNOT_FONT_SIZE=14
psscale -D0.5/14/5/0.3 -B0.2:"Presence": -C./cpts/$(basename ${infile%.*}_likelihood.cpt) -O >> $outfile

formats $outfile
