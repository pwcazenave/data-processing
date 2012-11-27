#!/bin/bash

# grid the height results

gmtdefaults -D > .gmtdefaults4

gmtset LABEL_FONT_SIZE=16 ANNOT_FONT_SIZE=16
gmtset D_FORMAT=%g PAPER_MEDIA=a4
gmtset COLOR_NAN=128/128/128

ssize=${ssize:-750}
infile=./raw_data/doris_${ssize}m_subset_results_errors_asymm.csv
bathyin=./grids/DORISall20m_interp_2m_subset.grd
maskin=./grids/DORISall20m_interp_2m_mask.grd
outfile=./images/$(basename ${infile%.*}_vectors_subset.ps)

area=$(grdinfo -I1 $bathyin)
atmp=($(grdinfo -C $bathyin))
west=${atmp[1]}
east=${atmp[2]}
south=${atmp[3]}
north=${atmp[4]}
unset atmp
parea=$area
harea=-R0/1/0/40
warea=-R20/50/0/30
darea=-R0/180/0/15
proj=-Jx0.0015
hproj=-JX6/2
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
	xyz2grd $parea $gres -F -G./grids/$(basename ${infile%.*}_heights_subset.grd)
#makecpt $(grdinfo -T0.1 ./grids/$(basename ${infile%.*}_heights_subset.grd)) -Cgray \
#makecpt -T-60/0/0.5 -Crainbow > ./cpts/$(basename ${infile%.*}_heights_subset.cpt)
grd2cpt -Crainbow -Z $bathyin > ./cpts/$(basename ${infile%.*}_heights_subset.cpt)

gmtset D_FORMAT=%.0f
psbasemap $parea $proj -Ba3000f1500:"Eastings":/a2000f1000:"Northings":WeSn \
	-Xc -Yc -K > $outfile
grdimage $parea $proj -C./cpts/$(basename ${infile%.*}_heights_subset.cpt) \
	$bathyin -I${bathyin%.*}_grad.grd -O -K >> $outfile
gmtset D_FORMAT=%g
#grd2xyz ./grids/$(basename ${infile%.*}_heights_subset.grd) | \
#	awk '{if ($3=="NaN") print $1,$2}' | \
#	psxy $parea $proj -Sx0.7 -O -K >> $outfile
#grd2xyz $maskin | grep -v "NaN" | \
#	psmask $parea $proj -I50 -F -N -S100 -G128/128/128 -O -K >> $outfile
#psmask -C -O -K >> $outfile
gmtset LABEL_FONT_SIZE=14 ANNOT_FONT_SIZE=14
psscale -D7.6/-2.3/-10/0.5h -I -B10:"Depth (m)": -C./cpts/$(basename ${infile%.*}_heights_subset.cpt) -O -K >> $outfile
# add in the vectors
awk -F, '{if ($3>2) print $1,$2,$4+90,0.675*(log($3)/log(10))}' $infile | \
	psxy $parea $proj -O -K -SVb0/0/0 -W5,white -Gwhite >> $outfile
# add in a key
echo "360000 82500 90 20" | awk '{print $1,$2,$3,0.5*(log($4)/log(10))}' | \
	psxy $parea $proj -O -K -SVb0/0/0 -W5 -Gblack >> $outfile
pstext $parea $proj -O -K -D0.75/-0.15 -WwhiteO0,white << LABEL >> $outfile
360000 82500 14 0 0 1 20 m wavelength
LABEL

# add in the histograms
gmtset ANNOT_FONT_SIZE=12
gmtset LABEL_OFFSET=0.15c ANNOT_OFFSET_PRIMARY=0.1c
# filter out all values below the nyquist frequency (2m)
#awk -F, '{if ($3>2 && $1>='$west' && $1<='$east' && $2>='$south' && $2<='$north') print $5}' $infile | \
#	pshistogram $harea $hproj -W0.05 -Ggray -L1 -O -K -Z1 \
#	-Ba0.5f0.1:,"-m":/a20f5:,"-%":WesN -X1.3 -Y12.5 >> $outfile
#pstext $harea $hproj -O -K << LABEL >> $outfile
#0.9 32 12 0 0 1 II
#LABEL
awk -F, '{if ($1>='$west' && $1<='$east' && $2>='$south' && $2<='$north') print $0}' $infile | \
	awk -F, '{if ($3>2 && $4<90) print $4+90,$4+90+$8,$4+90-$9; else print $4-90,$4-90+$8,$4-90-$9}' | tr " " "\n" | \
	pshistogram $darea $hproj -W5 -Ggray -L1 -O -T0 -Z1 \
	-Ba90f10:,"-@+o@+":/a5f1:,"-%":WesN -X5 -Y12.5 >> $outfile
#pstext $darea $hproj -O -K << LABEL >> $outfile
#155 8 12 0 0 1 III
#LABEL
#awk -F, '{if ($3>2 && $1>='$west' && $1<='$east' && $2>='$south' && $2<='$north') print $3}' $infile | \
#	pshistogram $warea $hproj -W1 -Ggray -L1 -O -Z1 \
#	-Ba10f5:,"-m":/a15f5:,"-%":WesN -X4.7 >> $outfile
#pstext $warea $hproj -O << LABEL >> $outfile
#28 12 12 0 0 1 I
#LABEL

formats $outfile
