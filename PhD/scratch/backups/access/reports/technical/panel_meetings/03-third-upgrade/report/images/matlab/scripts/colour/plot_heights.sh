#!/bin/bash

# grid the height results

gmtset LABEL_FONT_SIZE=18 ANNOT_FONT_SIZE=18
gmtset D_FORMAT=%g PAPER_MEDIA=a4

area=-R578106/588473/91505/98705
parea=-R578106/590473/91505/98705
harea=-R0/1.2/0.001/45
darea=-R0/179.99/0.001/10
proj=-Jx0.00215
hproj=-JX6/3.6
gres=-I300

infile=../../hsb_2005_300m_subset_results.csv
outfile=./images/$(basename ${infile%.*}_heights_vectors.ps)

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
#makecpt $(grdinfo -T0.1 ./grids/$(basename ${infile%.*}_heights.grd)) -Crainbow \
makecpt -T-0.1/1/0.01 -Crainbow \
   > ./cpts/$(basename ${infile%.*}_heights.cpt)

gmtset D_FORMAT=%.0f
psbasemap $area $proj -Ba2000f500:"Eastings":/a1000f500:"Northings":WeSn \
   -Xc -Yc -K > $outfile
grdimage $area $proj -C./cpts/$(basename ${infile%.*}_heights.cpt) \
   ./grids/$(basename ${infile%.*}_heights.grd) -O -K >> $outfile
gmtset D_FORMAT=%g
psscale -D23/8/7/0.5 -B0.2:"Height (m)": -C./cpts/$(basename ${infile%.*}_heights.cpt) -O -K >> $outfile
grd2xyz ./grids/$(basename ${infile%.*}_heights.grd) | \
   awk '{if ($3=="NaN") print $1,$2}' | \
   psxy $area $proj -Sx0.9 -O -K >> $outfile
awk -F, '{print $1,$2,$5}' $infile | \
   psmask $area $proj $gres -F -N -S350 -G128/128/128 -O -K >> $outfile
psmask -C -O -K >> $outfile
pshistogram $harea $hproj $infile -W0.05 -Ggray -L1 -O -K -T4 -Z1 \
   -Ba0.5f0.1:,"-m":/a20f5:,"-%":WN -X16.25 -Y0.03 >> $outfile
# add in the vectors
awk -F, '{print $1,$2,$4,0.5*(log($3)/log(10))}' $infile | \
   psxy $area $proj -O -K -SVb0/0/0 -W5/255/255/255 -Gwhite >> $outfile
# add in a key
echo "578750 98250 90 20" | awk '{print $1,$2,$3,0.5*(log($4)/log(10))}' | \
psxy $area $proj -O -K -SVb0/0/0 -W5 -Gblack >> $outfile
pstext $area $proj -O -K -D0.75/-0.15 -WwhiteO0,white << LABEL >> $outfile
578750 98250 14 0 0 1 20 m wavelength
LABEL
pshistogram $harea $hproj $infile -W5 -Ggray -L1 -O -T3 -Z1 \
   -Ba45f10:,"-@+o@+":/a5f1:,"-%":WN -X16.25 -Y0.03 >> $outfile

formats $outfile
