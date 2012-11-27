#!/bin/bash

# Plot the DORIS bathy and results, plus a subset.
set -e

gmtdefaults -D > .gmtdefaults4

gmtset LABEL_FONT_SIZE=16 ANNOT_FONT_SIZE=16
gmtset D_FORMAT=%g PAPER_MEDIA=a4
gmtset COLOR_NAN=128/128/128

ssize=${ssize:-750}
infile=./raw_data/doris_${ssize}m_subset_results_errors_asymm.csv
bathyin=./grids/DORISall20m_interp_2m.grd
sbathyin=./grids/DORISall2m_interp_2m_subset.grd
maskin=./grids/DORISall20m_interp_2m_mask.grd
interp=./raw_data/doris_${ssize}m_interp.xy
outfile=./images/$(basename ${infile%.*}_vectors.ps)

area=$(grdinfo -I1 $bathyin)
atmp=($(grdinfo -C $sbathyin))
west=${atmp[1]}
east=${atmp[2]}
south=${atmp[3]}
north=${atmp[4]}
unset atmp
sarea=-R$west/$east/$south/$north
parea=$area
darea=-R0/180/0/15
proj=-Jx0.00028
sproj=-Jx0.00075
hproj=-JX5.3/5.5
gres=-I${ssize}

gmtset LABEL_FONT_SIZE=14 ANNOT_FONT_SIZE=14 D_FORMAT=%g PAPER_MEDIA=a4 COLOR_NAN=128/128/128

awk -F, '{if ($3>2) print $1,$2,$5}' $infile | \
   xyz2grd $parea $gres -F -G./grids/$(basename ${infile%.*}_heights.grd)
makecpt -T-110/0/0.5 -Cgray > ./cpts/$(basename ${infile%.*}_heights.cpt)

# The bathy panel
gmtset D_FORMAT=%.0f
psbasemap $parea $proj -Ba10000f5000:"Eastings":/a5000f2500:"Northings":Wesn \
   -X3 -Y16.2 -K -P > $outfile
grdimage $parea $proj -C./cpts/$(basename ${infile%.*}_heights.cpt) \
	$bathyin -I${bathyin%.*}_grad.grd -O -K >> $outfile
# Add the subset box
psxy $parea $proj -O -K -L -W8,black << BOX >> $outfile
$west $south
$west $north
$east $north
$east $south
BOX
gmtset D_FORMAT=%g LABEL_FONT_SIZE=10 ANNOT_FONT_SIZE=10 ANNOT_OFFSET_PRIMARY=0.15c LABEL_OFFSET=0.15c
psscale -D11/6.3/4.5/0.3h -I -B20:"Depth (m)": -C./cpts/$(basename ${infile%.*}_heights.cpt) -O -K >> $outfile

# The bathy+vectors panel
gmtset D_FORMAT=%.0f D_FORMAT=%g LABEL_FONT_SIZE=14 ANNOT_FONT_SIZE=14 LABEL_OFFSET=0.3c
psbasemap $parea $proj -Ba10000f5000:"Eastings":/a5000f2500:"Northings":WeSn \
   -Y-7 -O -K >> $outfile
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
# add in the vectors
awk -F, '{if ($3>2) print $1,$2,$4+90,0.25}' $infile | \
   psxy $parea $proj -O -K -SVb0/0/0 -W5,white -Gwhite >> $outfile
psxy $parea $proj -O -K -L -W8,black << BOX >> $outfile
$west $south
$west $north
$east $north
$east $south
BOX

# Add the interp
psxy $parea $proj -O -K -W10,black -M $interp >> $outfile

# The subset panel
makecpt -T-60/-10/0.5 -Cgray > ./cpts/$(basename ${infile%.*}_heights_subset.cpt)

gmtset D_FORMAT=%.0f
psbasemap $sarea $sproj -Ba3000f1500:"Eastings":/a2000f1000:"Northings":WeSn \
	-Y-7.5 -O -K >> $outfile
grdimage $sarea $sproj -C./cpts/$(basename ${infile%.*}_heights_subset.cpt) \
	$sbathyin -I${sbathyin%.*}_grad.grd -O -K >> $outfile
gmtset D_FORMAT=%g
gmtset LABEL_FONT_SIZE=8 ANNOT_FONT_SIZE=8 ANNOT_OFFSET_PRIMARY=0.1c
psscale -D6.4/5.5/2/0.15h -I -B20 -C./cpts/$(basename ${infile%.*}_heights_subset.cpt) -O -K >> $outfile
gmtset LABEL_FONT_SIZE=14 ANNOT_FONT_SIZE=14
# add in the vectors
awk -F, '{if ($3>2) print $1,$2,$4+90,0.5}' $infile | \
	psxy $sarea $sproj -O -K -SVb0/0/0 -W5,white -Gwhite >> $outfile

# The subset histogram
# filter out all values below the nyquist frequency (2m)
awk -F, '{
	if ($3>2 && $4<90 && $1>='$west' && $1<='$east' && $2>='$south' && $2<='$north')
		print $4+90,$4+90+$8,$4+90-$9;
	else
	if ($3>2 && $4>=90 && $1>='$west' && $1<='$east' && $2>='$south' && $2<='$north')
		print $4-90,$4-90+$8,$4-90-$9
	}' ${infile} | \
   tr " " "\n" | \
   pshistogram $darea $hproj -W5 -Ggray -L1 -O -T0 -Z1 \
   -Ba45f15:"Strike"::,"-@+o@+":/a5f1:,"-%":WeSn -X9.2 >> $outfile

formats $outfile
