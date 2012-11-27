#!/bin/bash

# grid the height results

gmtdefaults -D > .gmtdefaults4

gmtset LABEL_FONT_SIZE=14 ANNOT_FONT_SIZE=14
gmtset D_FORMAT=%g PAPER_MEDIA=a4
gmtset COLOR_NAN=128/128/128

infile=../ws_200m_subset_results_errors.csv
# use the 5m gridded bathy for the mask area to show where the nan results are
maskin=../ws_mask_bathy_50m.xyz
outfile=./images/$(basename ${infile%.*}_heights_vectors.ps)

area=-R598201/618927/5613228/5627356
parea=$area
harea=-R0/1/0/20
warea=-R0/30/0/10
darea=-R0/180/0/10
proj=-Jx0.0012
hproj=-JX3.2/2
gres=-I200

formats(){
   echo -n "converting to pdf "
   ps2pdf -sPAPERSIZE=a4 -dPDFSETTINGS=/prepress -q $1 ${outfile%.*}.pdf
   echo -n "and png... "
   gs -sDEVICE=png16m -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q \
      -sOutputFile=${1%.ps}.png $outfile
   echo "done."
}

awk -F, '{if ($3>2) print $1,$2,$5}' $infile | \
   xyz2grd $parea $gres -F -G./grids/$(basename ${infile%.*}_heights.grd)
#makecpt $(grdinfo -T0.1 ./grids/$(basename ${infile%.*}_heights.grd)) -Cgray \
makecpt -T0/1/0.01 -Cgray \
   > ./cpts/$(basename ${infile%.*}_heights.cpt)

gmtset D_FORMAT=%.0f
psbasemap $parea $proj -Ba4000f1000:"Eastings":/a2000f1000:"Northings":WeSn \
   -X4.2 -Yc -K > $outfile
grdimage $parea $proj -C./cpts/$(basename ${infile%.*}_heights.cpt) \
   ./grids/$(basename ${infile%.*}_heights.grd) -O -K >> $outfile
gmtset D_FORMAT=%g
grd2xyz ./grids/$(basename ${infile%.*}_heights.grd) | \
   awk '{if ($3=="NaN") print $1,$2}' | \
   psxy $parea $proj -Sx0.9 -O -K >> $outfile
#awk -F, '{print $1,$2,$5}' $infile | \
   psmask $maskin $parea $proj $gres -F -N -S350 -G128/128/128 -O -K >> $outfile
psmask -C -O -K >> $outfile
# Add in the IOW and Hampshire coastlines
psxy $area $proj -O -K -W5,black -Gwhite -B0 $(pwd)/iow_coastline.txt -: >> $outfile
psxy $area $proj -O -K -W5,black -Gwhite -B0 $(pwd)/south_coastline.txt >> $outfile
psscale -D0.5/14/5/0.3 -B0.2:"Height (m)": -C./cpts/$(basename ${infile%.*}_heights.cpt) -O -K >> $outfile
# add in the vectors
awk -F, '{if ($3>2) print $1,$2,$4,0.2*(log($3)/log(10))}' $infile | \
   psxy $parea $proj -O -K -SVb0/0/0 -W5/255/255/255 -Gwhite >> $outfile
# add in a key
echo "604000 5626600 90 20" | awk '{print $1,$2,$3,0.4*(log($4)/log(10))}' | \
psxy $parea $proj -O -K -SVb0/0/0 -W5 -Gblack >> $outfile
pstext $parea $proj -O -K -D0.75/-0.15 -WwhiteO0,white << LABEL >> $outfile
604000 5626600 14 0 0 1 20 m wavelength
LABEL
# add in the histograms
gmtset ANNOT_FONT_SIZE=12
gmtset LABEL_OFFSET=0.15c ANNOT_OFFSET_PRIMARY=0.1c
# filter out all values where lambda<2m (nyquist freq).
awk -F, '{if ($3>2) print $5}' $infile | \
   pshistogram $harea $hproj -W0.05 -Ggray -L1 -O -K -Z1 \
   -Ba0.5f0.1:,"-m":/a10f5:,"-%":WesN -X16 -Y0.35 >> $outfile
#pstext $harea $hproj -O -K << LABEL >> $outfile
#0.9 32 12 0 0 1 II
#LABEL
awk -F, '{if ($3>2) print $4,$4+$8,$4-$9}' $infile | tr " " "\n" | \
   pshistogram $darea $hproj -W5 -Ggray -L1 -O -K -T0 -Z1 \
   -Ba90f10:,"-@+o@+":/a5f1:,"-%":wEsN -X4.2 >> $outfile
#pstext $darea $hproj -O -K << LABEL >> $outfile
#155 8 12 0 0 1 III
#LABEL
awk -F, '{if ($3>2) print $3}' $infile | \
   pshistogram $warea $hproj -W1 -Ggray -L1 -O -Z1 \
   -Ba15f5:,"-m":/a5f1:,"-%":wEsN -Y3.1 >> $outfile
#pstext $warea $hproj -O << LABEL >> $outfile
#28 12 12 0 0 1 I
#LABEL

formats $outfile
