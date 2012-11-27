#!/bin/bash

# grid the height results

set -e

gmtdefaults -D > .gmtdefaults4

gmtset LABEL_FONT_SIZE=16 ANNOT_FONT_SIZE=16
gmtset D_FORMAT=%g PAPER_MEDIA=a4
gmtset COLOR_NAN=128/128/128

ssize=${ssize:-750}
infile=./raw_data/doris_${ssize}m_subset_results_errors_asymm.csv
bathyin=./grids/DORISall20m_interp_2m.grd
maskin=./grids/DORISall20m_interp_2m_mask.grd
outfile=./images/$(basename ${infile%.*}_vectors.ps)

area=$(grdinfo -I1 $bathyin)
parea=$area
harea=-R0/1/0/40
warea=-R30/60/0/30
darea=-R0/180/0/20
proj=-Jx0.0005
hproj=-JX10/2
gres=-I${ssize}

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
makecpt -T-110/0/0.5 -Crainbow \
   > ./cpts/$(basename ${infile%.*}_heights.cpt)

gmtset D_FORMAT=%.0f
psbasemap $parea $proj -Ba10000f5000:"Eastings":/a5000f2500:"Northings":WeSn \
   -X3.2 -Yc -K > $outfile
grdimage $parea $proj -C./cpts/$(basename ${infile%.*}_heights.cpt) \
	$bathyin -I${bathyin%.*}_grad.grd -O -K >> $outfile
gmtset D_FORMAT=%g
grd2xyz ./grids/$(basename ${infile%.*}_heights.grd) | \
   awk '{if ($3=="NaN") print $1,$2}' | \
   psxy $parea $proj -Sx0.7 -O -K >> $outfile
grd2xyz $maskin | grep -v "NaN" | \
   psmask $parea $proj -I50 -F -N -S100 -G128/128/128 -O -K >> $outfile
psmask -C -O -K >> $outfile
gmtset LABEL_FONT_SIZE=14 ANNOT_FONT_SIZE=14
psscale -D13/-2.3/10/0.5h -I -B20:"Depth (m)": -C./cpts/$(basename ${infile%.*}_heights.cpt) -O -K >> $outfile
# add in the vectors
awk -F, '{if ($3>2) print $1,$2,$4,0.2*(log($3)/log(10))}' $infile | \
   psxy $parea $proj -O -K -SVb0/0/0 -W5/255/255/255 -Gwhite >> $outfile
# add in a key
#echo "360000 82500 90 20" | awk '{print $1,$2,$3,0.5*(log($4)/log(10))}' | \
#	psxy $parea $proj -O -K -SVb0/0/0 -W5 -Gblack >> $outfile
#pstext $parea $proj -O -K -D0.75/-0.15 -WwhiteO0,white << LABEL >> $outfile
#360000 82500 14 0 0 1 20 m wavelength
#LABEL

# add in the histograms
gmtset ANNOT_FONT_SIZE=12
gmtset LABEL_OFFSET=0.15c ANNOT_OFFSET_PRIMARY=0.1c
# filter out all values below the nyquist frequency (2m)
#awk -F, '{if ($3>2) print $5}' $infile | \
#pshistogram $harea $hproj -W0.05 -Ggray -L1 -O -K -Z1 \
#   -Ba0.5f0.1:,"-m":/a20f5:,"-%":WesN -X7 -Y12.5 >> $outfile
#pstext $harea $hproj -O -K << LABEL >> $outfile
#0.9 32 12 0 0 1 II
#LABEL
awk -F, '{if ($3>2) print $4,$4+$8,$4-$9}' ${infile} | tr " " "\n" | \
   pshistogram $darea $hproj -W5 -Ggray -L1 -O -T0 -Z1 \
   -Ba30f5:,"-@+o@+":/a10f2:,"-%":WesN -X8 -Y12.5>> $outfile
#pstext $darea $hproj -O -K << LABEL >> $outfile
#155 8 12 0 0 1 III
#LABEL
#awk -F, '{if ($3>2) print $3}' $infile | \
#   pshistogram $warea $hproj -W1 -Ggray -L1 -O -Z1 \
#   -Ba10f5:,"-m":/a15f5:,"-%":WesN -X4.7 >> $outfile
#pstext $warea $hproj -O << LABEL >> $outfile
#28 12 12 0 0 1 I
#LABEL

formats $outfile
