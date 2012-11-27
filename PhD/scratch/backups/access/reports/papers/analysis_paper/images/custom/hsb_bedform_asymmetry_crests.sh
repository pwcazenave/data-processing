#!/bin/bash

# grid the height results

gmtdefaults -D > .gmtdefaults4

gmtset LABEL_FONT_SIZE=16 ANNOT_FONT_SIZE=16
gmtset D_FORMAT=%g PAPER_MEDIA=a4
gmtset COLOR_NAN=128/128/128

area=-R578106/588473/91505/98705
parea=-R578106/589473/91505/98705
harea=-R0/1/0/30
warea=-R10/30/0/20
darea=-R0/360/0/10
proj=-Jx0.00215
hproj=-JX3.2/2
gres=-I300

infile=./raw_data/hsb_300m_subset_results_errors_asymm.csv
outfile=./images/$(basename ${infile%.*}_height_asymmetry_crest_bedform.ps)

formats(){
	echo -n "converting to pdf "
	ps2pdf -sPAPERSIZE=a4 -dPDFSETTINGS=/prepress -q $1 ${outfile%.*}.pdf
	echo -n "and png... "
	gs -sDEVICE=png16m -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q \
		-sOutputFile=${1%.ps}.png $outfile
	echo "done."
}

awk -F, '{if ($3>2 && $15==1) print $1,$2,$5}' $infile | \
	xyz2grd $parea $gres -F -G./grids/$(basename ${infile%.*}_heights.grd)
awk -F, '{if ($3>2) print $1,$2,0}' $infile | \
	xyz2grd $parea $gres -F -G./grids/$(basename ${infile%.*}_coverage.grd)
#makecpt $(grdinfo -T0.1 ./grids/$(basename ${infile%.*}_heights.grd)) -Cgray \
makecpt -T0/1/0.01 -Cgray > ./cpts/$(basename ${infile%.*}_heights.cpt)

gmtset D_FORMAT=%.0f
psbasemap $parea $proj -Ba2000f500:"Eastings":/a1000f500:"Northings":WeSn \
	-X3.2 -Yc -K > $outfile
grdimage $parea $proj -C./cpts/$(basename ${infile%.*}_heights.cpt) \
	./grids/$(basename ${infile%.*}_heights.grd) -O -K >> $outfile
gmtset D_FORMAT=%g
# Add grid of boxes over entire domain
grd2xyz ./grids/$(basename ${infile%.*}_heights.grd) | \
	awk '{if ($3=="NaN") print $1,$2}' | \
	psxy $parea $proj -Ss0.915 -O -K >> $outfile
# Add crosses where we don't have a result at all
grd2xyz ./grids/$(basename ${infile%.*}_coverage.grd) | \
	awk '{if ($3=="NaN") print $1,$2}' | \
	psxy $parea $proj -Sx0.9 -O -K >> $outfile
awk -F, '{print $1,$2,$5}' $infile | \
	psmask $parea $proj $gres -F -N -G128/128/128 -S350 -O -K >> $outfile
psmask -C -O -K >> $outfile
gmtset LABEL_FONT_SIZE=14 ANNOT_FONT_SIZE=14
psscale -D22/12.7/5/0.3 -B0.2:"Height (m)": -C./cpts/$(basename ${infile%.*}_heights.cpt) -O -K >> $outfile
# Add in the crest vectors
awk -F, '{if ($3>8 && $15==1) print $1,$2,$4+90,0.5}' $infile | grep -v NaN | \
	psxy $parea $proj -O -K -SVb0/0/0 -W6,white -Gblack >> $outfile
# Add in the asymmetry vectors
awk -F, '{if ($3>8 && $15==1) print $1,$2,$14,0.5}' $infile | grep -v NaN | \
	psxy $parea $proj -O -K -SVb0/0.25/0.1 -W6,white -Gblack >> $outfile
# Add in the ADCP vector directions for the 3 locations
psxy $parea $proj -SV0.2/0.25/0.25 -W10,white -Ggray -O -K << ADCP >> $outfile
583705 97026 50 1.5
582840 94770 62 1.5
582994 93915 52 1.5
ADCP
pstext $parea $proj -N -O -K -WwhiteO0,white -D0.1/-0.6 << ADCP >> $outfile
583705 97026 12 0 0 1 Site 1
582840 94770 12 0 0 1 Site 2
582994 93915 12 0 0 1 Site 3
ADCP
# Add the licence area outline
psxy $parea $proj -O -K -W5,white -L ./raw_data/hsb_licence.xy >> $outfile

# add in the histograms
gmtset ANNOT_FONT_SIZE=12
gmtset LABEL_OFFSET=0.15c ANNOT_OFFSET_PRIMARY=0.1c
# filter out all values below the nyquist frequency (2m)
awk -F, '{if ($3>2 && $15==1) print $5}' $infile | grep -v NaN | \
	pshistogram $harea $hproj -W0.05 -Ggray -L1 -O -K -Z1 \
	-Ba0.5f0.1:,"-m":/a15f5:,"-%":WesN -X15.5 -Y0.35 >> $outfile
#pstext $harea $hproj -O -K << LABEL >> $outfile
#0.9 32 12 0 0 1 II
#LABEL
awk -F, '{if ($3>2 && $15==1) print $14}' ${infile} | tr " " "\n" | grep -v NaN | \
	pshistogram $darea $hproj -W5 -Ggray -L1 -O -K -T0 -Z1 \
	-Ba180f20:,"-@+o@+":/a5f2.5:,"-%":wEsN -X4.2 >> $outfile
#pstext $darea $hproj -O -K << LABEL >> $outfile
#155 8 12 0 0 1 III
#LABEL
awk -F, '{if ($3>2 && $15==1) print $3}' $infile | grep -v NaN | \
	pshistogram $warea $hproj -W1 -Ggray -L1 -O -Z1 \
	-Ba10f5:,"-m":/a10f5:,"-%":wEsN -Y3.1 >> $outfile
#pstext $warea $hproj -O << LABEL >> $outfile
#28 12 12 0 0 1 I
#LABEL

formats $outfile
