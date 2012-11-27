#!/bin/bash

# grid the height results

gmtset LABEL_FONT_SIZE=18 ANNOT_FONT_SIZE=18
gmtset D_FORMAT=%g PAPER_MEDIA=a4

area=-R578106/588473/91505/98705
harea=-R0/1.2/0.001/45
proj=-Jx0.00215
hproj=-JX6/3.6
gres=-I300

infile=../hsb_2005_300m_subset_results.csv
outfile=./images/$(basename ${infile%.*}_heights.ps)

formats(){
   echo -n "converting to pdf "
   ps2pdf -sPAPERSIZE=a4 -dPDFSETTINGS=/prepress -q $1 ${outfile%.*}.pdf
   echo -n "and png... "
   gs -sDEVICE=png16m -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q \
      -sOutputFile=${1%.ps}.png $outfile
   echo "done."
}

awk -F, '{print $1,$2,$5}' $infile | \
   xyz2grd $area $gres -F -G./grids/$(basename ${infile%.*}_heights.grd)
#makecpt $(grdinfo -T0.1 ./grids/$(basename ${infile%.*}_heights.grd)) -Cgray \
makecpt -T-0.1/1/0.01 -Cgray \
   > ./cpts/$(basename ${infile%.*}_heights.cpt)

grdsample -F $gres ./grids/all_lines_blockmedian_1m_mask.grd \
   -G./grids/$(basename ${infile%.*}_mask_resampled.grd)
grd2xyz ./grids/$(basename ${infile%.*}_mask_resampled.grd) | \
   awk '{if ($3=="NaN") print $1,$2,0; else print $1,$2,1}' | \
   xyz2grd -F $area $gres \
   -G./grids/$(basename ${infile%.*}_mask_transparent.grd)

gmtset D_FORMAT=%.0f
grdimage $area $proj -C./cpts/$(basename ${infile%.*}_heights.cpt) \
   ./grids/$(basename ${infile%.*}_heights.grd) -Xc -Yc -K \
   -Ba2000f500:"Eastings":/a1000f500:"Northings":WeSn > $outfile
gmtset D_FORMAT=%g
psscale -D23/8/7/0.5 -B0.2:"Height (m)": -C./cpts/$(basename ${infile%.*}_heights.cpt) -O -K >> $outfile
grd2xyz ./grids/$(basename ${infile%.*}_heights.grd) | \
   awk '{if ($3=="NaN") print $1,$2}' | \
   psxy $area $proj -Sx0.9 -O -K >> $outfile
awk -F, '{print $1,$2,$5}' $infile | \
   psmask $area $proj $gres -F -N -S350 -G128/128/128 -O -K >> $outfile
psmask -C -O -K >> $outfile
pshistogram $harea $hproj $infile -W0.05 -Ggray -L1 -O -T4 -Z1 \
   -Ba0.5f0.1:,"-m":/a20f5:,"-%":WN -X16.25 -Y0.03 >> $outfile

formats $outfile
