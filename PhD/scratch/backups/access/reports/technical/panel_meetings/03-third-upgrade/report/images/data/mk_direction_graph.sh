#!/bin/bash

# script to plot the direction dependent error in profiling the seabed

gmtdefaults -D > .gmtdefaults4
gmtset LABEL_FONT_SIZE=20
gmtset ANNOT_FONT_SIZE_PRIMARY=20

infile=./direction_sampling_percentage_error.csv
outfile=${infile%.csv}.ps

# area=$(minmax -I1 $infile)
area=-R0/90/0.01/5630
proj=-JX20/15l

mkplot(){
	psxy $area $proj $infile -W5 -Sx0.2 -G0/0/0 -Xc -Yc -K \
		-Ba10f5:,-@+o@+::"Sampling orientation":/a1f0.5:,-%::"Wavelength Error":WeSn \
		> $outfile
	psxy $area $proj $infile -W5 -O >> $outfile
}

formats(){
   echo -n "converting to pdf "
   ps2pdf -sPAPERSIZE=a4 -dPDFSETTINGS=/prepress -q $1 \
      ${1%.ps}.pdf
   echo -n "and jpeg... "
   gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q \
      -sOutputFile=${1%.ps}.jpg $1
   echo "done."
}

mkplot
formats $outfile

eog ${outfile%.ps}.jpg

exit 0
