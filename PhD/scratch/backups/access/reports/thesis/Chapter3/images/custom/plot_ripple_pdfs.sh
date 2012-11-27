#!/bin/bash

# Script to plot the discrepancies between the observations and prections 
# for the heights.

gmtset LABEL_FONT_SIZE=14 ANNOT_FONT_SIZE=14
gmtset D_FORMAT=%g PAPER_MEDIA=a4

area=-R-1/6/0/1
proj=-JX7/10
bproj=-Jx0.1
tproj=-JX15/25

infileBathy=./raw_data/ripple_model_bathy.csv
infileHeight=./raw_data/pdfs/ripple_model_pdfs.csv

outfile=./images/ripple_model_pdfs.ps

# Some custom greys
gray1=50/50/50
gray2=100/100/100
gray3=150/150/150
gray4=200/200/200

plotbathy(){
    base=$(basename $infileBathy .csv)
    barea=$(minmax -I1 $infileBathy)
    barea=-R0/100/0/100
    xyz2grd $infileBathy $barea -I0.25 -G./grids/$base.grd
    grdgradient -Nt0.7 -A180 ./grids/$base.grd -G./grids/"$base"_grad.grd
    makecpt $(grdinfo -T0.05 ./grids/$base.grd) -Z > ./cpts/$base.cpt
    makecpt -T-1.5/1.5/0.1 -Cwysiwyg -Z > ./cpts/$base.cpt

    grdimage $barea $bproj -C./cpts/$base.cpt ./grids/$base.grd \
        -I./grids/"$base"_grad.grd -X5 -Y10c -K \
        -Ba20f5WeSn > $outfile
    psscale -D-3.5/5/5/0.3 -I -Ba0.5f0.1:"Elevation": -O -K -C./cpts/$base.cpt >> $outfile
}


plotheight(){
	psbasemap $area $proj -X13 -O -K \
		-Ba1f0.2:"Dimensionless height":/a0.2f0.05:"Probability density":WeSn >> $outfile
	# Observed
	cut -f1,2 -d, $infileHeight | \
		psxy $area $proj -Sb0.07 -O -K -Ggrey -W5,grey >> $outfile
	# Exponential
	cut -f1,3 -d, $infileHeight | \
		psxy $area $proj -O -K -W4,black >> $outfile
	# Gamma
	cut -f1,4 -d, $infileHeight | \
		psxy $area $proj -O -K -W10,black >> $outfile
	# Gaussian
	cut -f1,5 -d, $infileHeight | \
		psxy $area $proj -O -K -W10,black,- >> $outfile
	# Gumbel
	cut -f1,6 -d, $infileHeight | \
		psxy $area $proj -O -K -W4,black,- >> $outfile
	# Log-normal
	cut -f1,7 -d, $infileHeight | \
		psxy $area $proj -O -K -W4,$gray2 >> $outfile
	# Rayleigh
	cut -f1,8 -d, $infileHeight | \
		psxy $area $proj -O -K -W10,$gray2 >> $outfile
	# Weibull
	cut -f1,9 -d, $infileHeight | \
		psxy $area $proj -O -K -W10,$gray2,- >> $outfile
	# Uniform
	cut -f1,10 -d, $infileHeight | \
		psxy $area $proj -O -K -W4,$gray2,- >> $outfile
	# Cauchy
	cut -f1,11 -d, $infileHeight | \
		psxy $area $proj -O -K -W4,$gray2,.- >> $outfile
}

plotlabel(){
	# Usage: labelY labelColour labelSymbol labelString

	# Add some labels
	xpos1=3.9 # text
	xpos2=2.5 # symbol start
	xpos3=3.8 # symbol end
	ypos1=$1 # label height
	labelColour=$2
	labelSize=$3
	labelString=$4
	out=$5
	labelStyle=$6

	pstext $area $proj -O -K -D0/-0.15 -Gblack << LABELS >> $out
$xpos1 $ypos1 10 0 0 1 ${labelString}
LABELS
	psxy $area $proj -O -K -W"${labelSize}","${labelColour}","${labelStyle}" << LINE >> $out
$xpos2 $ypos1
$xpos3 $ypos1
LINE
}

plotbathy
plotheight
plotlabel 0.95 grey 15 "Observed" $outfile
plotlabel 0.90 black 4 "Exponential" $outfile
plotlabel 0.85 black 10  "Gamma" $outfile
plotlabel 0.80 black 10 "Gaussian" $outfile -
plotlabel 0.75 black 4 "Gumbel" $outfile - 
plotlabel 0.70 $gray2 4 "Log-normal" $outfile
plotlabel 0.65 $gray2 10 "Rayleigh" $outfile
plotlabel 0.60 $gray2 10 "Weibull" $outfile -
plotlabel 0.55 $gray2 4 "Uniform" $outfile -
plotlabel 0.50 $gray2 4 "Cauchy" $outfile .-

psxy $area $proj -T -O >> $outfile
formats $outfile
mv $outfile ./images/ps/
mv ${outfile%.*}.png ./images/png/
