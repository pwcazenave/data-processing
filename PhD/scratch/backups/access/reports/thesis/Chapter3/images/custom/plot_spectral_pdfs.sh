#!/bin/bash

# Script to plot the discrepancies between the observations and prections 
# for the heights.

gmtset LABEL_FONT_SIZE=14 ANNOT_FONT_SIZE=14
gmtset D_FORMAT=%g PAPER_MEDIA=a4

area=-R-1/6/0/3
proj=-JX7/10
tproj=-JX15/25

infileMarineWavelength=./raw_data/pdfs/marine_lambda_spectral_pdfs.csv
infileAeolianWavelength=./raw_data/pdfs/aeolian_lambda_spectral_pdfs.csv

outfile=./images/spectral_bedform_pdfs.ps

# Some custom greys
gray1=50/50/50
gray2=100/100/100
gray3=150/150/150
gray4=200/200/200

plotMarine(){
	psbasemap $area $proj -X3 -Y18c -K -P \
		-Ba1f0.2:"Dimensionless wavenumber":/a0.5f0.1:"Probability density":WeSn > $outfile
	# Wavelength
	# Observed
	cut -f1,2 -d, $infileMarineWavelength | \
		psxy $area $proj -Sb0.017 -O -K -Ggrey -W5,grey >> $outfile
	# Exponential
	cut -f1,3 -d, $infileMarineWavelength | \
		psxy $area $proj -O -K -W4,black >> $outfile
	# Gamma
	cut -f1,4 -d, $infileMarineWavelength | \
		psxy $area $proj -O -K -W10,black >> $outfile
	# Gaussian
	cut -f1,5 -d, $infileMarineWavelength | \
		psxy $area $proj -O -K -W10,black,- >> $outfile
	# Gumbel
	cut -f1,6 -d, $infileMarineWavelength | \
		psxy $area $proj -O -K -W4,black,- >> $outfile
	# Log-normal
	cut -f1,7 -d, $infileMarineWavelength | \
		psxy $area $proj -O -K -W4,$gray2 >> $outfile
	# Rayleigh
	cut -f1,8 -d, $infileMarineWavelength | \
		psxy $area $proj -O -K -W10,$gray2 >> $outfile
	# Weibull
	cut -f1,9 -d, $infileMarineWavelength | \
		psxy $area $proj -O -K -W10,$gray2,- >> $outfile
	# Uniform
	cut -f1,10 -d, $infileMarineWavelength | \
		psxy $area $proj -O -K -W4,$gray2,- >> $outfile
	# Cauchy
	cut -f1,11 -d, $infileMarineWavelength | \
		psxy $area $proj -O -K -W4,$gray2,.- >> $outfile
    pstext $area $proj -O -K -N << TEXT >> $outfile
-1 3.1 16 0 0 1 A
TEXT
}

plotAeolian(){
	psbasemap $area $proj -X8c -O -K -P \
		-Ba1f0.2:"Dimensionless wavenumber":/a0.5f0.1:"Probability density":wESn >> $outfile
	# Wavelength
	# Observed
	cut -f1,2 -d, $infileAeolianWavelength | \
		psxy $area $proj -Sb0.017 -O -K -Ggrey -W5,grey >> $outfile
	# Exponential
	cut -f1,3 -d, $infileAeolianWavelength | \
		psxy $area $proj -O -K -W4,black >> $outfile
	# Gamma
	cut -f1,4 -d, $infileAeolianWavelength | \
		psxy $area $proj -O -K -W10,black >> $outfile
	# Gaussian
	cut -f1,5 -d, $infileAeolianWavelength | \
		psxy $area $proj -O -K -W10,black,- >> $outfile
	# Gumbel
	cut -f1,6 -d, $infileAeolianWavelength | \
		psxy $area $proj -O -K -W4,black,- >> $outfile
	# Log-normal
	cut -f1,7 -d, $infileAeolianWavelength | \
		psxy $area $proj -O -K -W4,$gray2 >> $outfile
	# Rayleigh
	cut -f1,8 -d, $infileAeolianWavelength | \
		psxy $area $proj -O -K -W10,$gray2 >> $outfile
	# Weibull
	cut -f1,9 -d, $infileAeolianWavelength | \
		psxy $area $proj -O -K -W10,$gray2,- >> $outfile
	# Uniform
	cut -f1,10 -d, $infileAeolianWavelength | \
		psxy $area $proj -O -K -W4,$gray2,- >> $outfile
	# Cauchy
	cut -f1,11 -d, $infileAeolianWavelength | \
		psxy $area $proj -O -K -W4,$gray2,.- >> $outfile
    pstext $area $proj -O -K -N << TEXT >> $outfile
-1 3.1 16 0 0 1 B
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

plotMarine
plotlabel 2.95 grey 15 "Observed" $outfile
plotlabel 2.85 black 4 "Exponential" $outfile
plotlabel 2.75 black 10  "Gamma" $outfile
plotlabel 2.65 black 10 "Gaussian" $outfile -
plotlabel 2.55 black 4 "Gumbel" $outfile -
plotlabel 2.45 $gray2 4 "Log-normal" $outfile
plotlabel 2.35 $gray2 10 "Rayleigh" $outfile
plotlabel 2.25 $gray2 10 "Weibull" $outfile -
plotlabel 2.15 $gray2 4 "Uniform" $outfile -
plotlabel 2.05 $gray2 4 "Cauchy" $outfile .-

plotAeolian
plotlabel 2.95 grey 15 "Observed" $outfile
plotlabel 2.85 black 4 "Exponential" $outfile
plotlabel 2.75 black 10  "Gamma" $outfile
plotlabel 2.65 black 10 "Gaussian" $outfile -
plotlabel 2.55 black 4 "Gumbel" $outfile -
plotlabel 2.45 $gray2 4 "Log-normal" $outfile
plotlabel 2.35 $gray2 10 "Rayleigh" $outfile
plotlabel 2.25 $gray2 10 "Weibull" $outfile -
plotlabel 2.15 $gray2 4 "Uniform" $outfile -
plotlabel 2.05 $gray2 4 "Cauchy" $outfile .-

psxy $area $proj -T -O >> $outfile
formats $outfile
mv $outfile ./images/ps/
mv ${outfile%.*}.png ./images/png/
