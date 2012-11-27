#!/bin/bash

# script to plot the synthetic surface in GMT ready for labelling
# in Inkscape

#gmtdefaults -D > .gmtdefaults4
#gmtset FRAME_PEN=3

infile=./bedform_measurements.csv
outfile=${infile%.csv}.ps
cptfile=${infile%.csv}.cpt
gridfile=${infile%.csv}.grd
gradfile=${infile%.csv}_grad.grd

area=$(minmax -I1 $infile)
proj=-JX20
zproj=-JZ3
gres=-I0.5

mkgrids(){
	xyz2grd $area $gres $infile -G$gridfile
	grdgradient -N0.3 -E210/70 $gridfile -G$gradfile
}

mkcpt(){
	makecpt -Cgray -T-1/0.5/0.01 -Z > $cptfile
}

mkplot(){
	grdview $area $proj $zproj -Bf2/f2/0WESNZ -C$cptfile -E100/30 \
		$gridfile -Qm -Xc -Yc -N-2 \
		> $outfile
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


#mkgrids
mkcpt
mkplot
formats $outfile

#eog ${outfile%.ps}.jpg

exit 0

