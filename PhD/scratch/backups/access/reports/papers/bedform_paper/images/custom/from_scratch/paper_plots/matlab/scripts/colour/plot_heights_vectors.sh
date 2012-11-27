#!/bin/bash

# grid the height results

gmtset LABEL_FONT_SIZE=14 ANNOT_FONT_SIZE=14
gmtset D_FORMAT=%g PAPER_MEDIA=a4 ANNOT_OFFSET_PRIMARY=0.1c LABEL_OFFSET=0.05c
gmtset COLOR_NAN=white

area=-R578106/588473/91505/98705
parea=-R578106/589473/91505/98705
harea=-R0/1/0.001/40
darea=-R0/180/0.001/10
proj=-Jx0.00215
hproj=-JX4/2.5
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
   xyz2grd $parea $gres -F -G./grids/$(basename ${infile%.*}_heights.grd)
#makecpt $(grdinfo -T0.1 ./grids/$(basename ${infile%.*}_heights.grd)) -Cseis \
makecpt -T0/1/0.01 -Cseis \
   > ./cpts/$(basename ${infile%.*}_heights.cpt)

gmtset D_FORMAT=%.0f
psbasemap $parea $proj -Ba2000f500:"Eastings":/a1000f500:"Northings":WeSn \
   -Xc -Yc -K > $outfile
grdimage $parea $proj -C./cpts/$(basename ${infile%.*}_heights.cpt) \
   ./grids/$(basename ${infile%.*}_heights.grd) -O -K >> $outfile
gmtset D_FORMAT=%g
grd2xyz ./grids/$(basename ${infile%.*}_heights.grd) | \
   awk '{if ($3=="NaN") print $1,$2}' | \
   psxy $parea $proj -Sx0.9 -O -K >> $outfile
awk -F, '{print $1,$2,$5}' $infile | \
   psmask $parea $proj $gres -F -N -S350 -Gwhite -O -K >> $outfile
psmask -C -O -K >> $outfile
psscale -D22.5/12.7/5/0.3 -B0.2:"Height (m)": -C./cpts/$(basename ${infile%.*}_heights.cpt) -O -K >> $outfile
# add in the vectors
awk -F, '{print $1,$2,$4,0.5*(log($3)/log(10))}' $infile | \
   psxy $parea $proj -O -K -SVb0/0/0 -W5/255/255/255 -Gwhite >> $outfile
# add in a key
echo "578750 98450 90 20" | awk '{print $1,$2,$3,0.5*(log($4)/log(10))}' | \
psxy $parea $proj -O -K -SVb0/0/0 -W5 -Gblack >> $outfile
pstext $parea $proj -O -K -D0.75/-0.15 -WwhiteO0,white << LABEL >> $outfile
578750 98450 14 0 0 1 20 m wavelength
LABEL
# add in the histograms
gmtset ANNOT_FONT_SIZE=12
pshistogram $harea $hproj $infile -W0.05 -Ggray -L1 -O -K -T4 -Z1 \
   -Ba0.5f0.1:,"-m":/a20f5:,"-%":WeN -X14.2 -Y0.01 >> $outfile
awk -F, '{print $4,$4+$8,$4-$9}' ${infile%.csv}_errors.csv | tr " " "\n" | \
   pshistogram $darea $hproj -W5 -Ggray -L1 -O -T0 -Z1 \
   -Ba90f10:,"-@+o@+":/a5f1:,"-%":wEN -X4.9 >> $outfile

formats $outfile
