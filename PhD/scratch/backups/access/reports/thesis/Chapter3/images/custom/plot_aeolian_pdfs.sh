#!/bin/bash

# Script to plot the discrepancies between the observations and prections 
# for the heights.

gmtset LABEL_FONT_SIZE=14 ANNOT_FONT_SIZE=14
gmtset D_FORMAT=%g PAPER_MEDIA=a4

area=-R-1/6/0/2.25
proj=-JX7/10
tproj=-JX15/25

infileHeight=./raw_data/pdfs/aeolian_height_pdfs.csv
infileWavelength=./raw_data/pdfs/aeolian_lambda_pdfs.csv

outfile=./images/aeolian_bedform_pdfs.ps

# Some custom greys
gray1=50/50/50
gray2=100/100/100
gray3=150/150/150
gray4=200/200/200

plotheight(){
	psbasemap $area $proj -X3 -Y18c -K -P \
		-Ba1f0.2:"Dimensionless height":/a0.2f0.05:"Probability density":WeSn > $outfile
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
    pstext $area $proj -O -K -N << TEXT >> $outfile
-1 2.35 16 0 0 1 A
TEXT


	# Aeolian
}

plotwavelength(){
	psbasemap $area $proj -X8c -O -K \
		-Ba1f0.2:"Dimensionless wavelength":/a0.2f0.05:"Probability density":wESn >> $outfile
	# Wavelength
	# Observed
	cut -f1,2 -d, $infileWavelength | \
		psxy $area $proj -Sb0.017 -O -K -Ggrey -W5,grey >> $outfile
	# Exponential
	cut -f1,3 -d, $infileWavelength | \
		psxy $area $proj -O -K -W4,black >> $outfile
	# Gamma
	cut -f1,4 -d, $infileWavelength | \
		psxy $area $proj -O -K -W10,black >> $outfile
	# Gaussian
	cut -f1,5 -d, $infileWavelength | \
		psxy $area $proj -O -K -W10,black,- >> $outfile
	# Gumbel
	cut -f1,6 -d, $infileWavelength | \
		psxy $area $proj -O -K -W4,black,- >> $outfile
	# Log-normal
	cut -f1,7 -d, $infileWavelength | \
		psxy $area $proj -O -K -W4,$gray2 >> $outfile
	# Rayleigh
	cut -f1,8 -d, $infileWavelength | \
		psxy $area $proj -O -K -W10,$gray2 >> $outfile
	# Weibull
	cut -f1,9 -d, $infileWavelength | \
		psxy $area $proj -O -K -W10,$gray2,- >> $outfile
	# Uniform
	cut -f1,10 -d, $infileWavelength | \
		psxy $area $proj -O -K -W4,$gray2,- >> $outfile
	# Cauchy
	cut -f1,11 -d, $infileWavelength | \
		psxy $area $proj -O -K -W4,$gray2,.- >> $outfile
    pstext $area $proj -O -K -N << TEXT >> $outfile
-1 2.35 16 0 0 1 B
TEXT
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

plotheight
plotlabel 2.2 grey 15 "Observed" $outfile
plotlabel 2.1 black 4 "Exponential" $outfile
plotlabel 2.0 black 10  "Gamma" $outfile
plotlabel 1.9 black 10 "Gaussian" $outfile -
plotlabel 1.8 black 4 "Gumbel" $outfile - 
plotlabel 1.7 $gray2 4 "Log-normal" $outfile
plotlabel 1.6 $gray2 10 "Rayleigh" $outfile
plotlabel 1.5 $gray2 10 "Weibull" $outfile -
plotlabel 1.4 $gray2 4 "Uniform" $outfile -
plotlabel 1.3 $gray2 4 "Cauchy" $outfile -

plotwavelength
plotlabel 2.2 grey 15 "Observed" $outfile
plotlabel 2.1 black 4 "Exponential" $outfile
plotlabel 2.0 black 10  "Gamma" $outfile
plotlabel 1.9 black 10 "Gaussian" $outfile -
plotlabel 1.8 black 4 "Gumbel" $outfile - 
plotlabel 1.7 $gray2 4 "Log-normal" $outfile
plotlabel 1.6 $gray2 10 "Rayleigh" $outfile
plotlabel 1.5 $gray2 10 "Weibull" $outfile -
plotlabel 1.4 $gray2 4 "Uniform" $outfile -
plotlabel 1.3 $gray2 4 "Cauchy" $outfile -

psxy $area $proj -T -O >> $outfile
formats $outfile
mv $outfile ./images/ps/
mv ${outfile%.*}.png ./images/png/
