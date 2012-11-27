#!/bin/bash

# grid the height results

gmtdefaults -D > .gmtdefaults4

gmtset LABEL_FONT_SIZE=16 ANNOT_FONT_SIZE=16
gmtset D_FORMAT=%g PAPER_MEDIA=a0
gmtset COLOR_NAN=128/128/128

bathyin=./grids/DORISall1m_interp_2m.grd
outfile=./images/$(basename ${bathyin%.*}.ps)

area=$(grdinfo -I1 $bathyin)
parea=$area
proj=-Jx0.00215

formats(){
   echo -n "converting to pdf "
   ps2pdf -sPAPERSIZE=a4 -dPDFSETTINGS=/prepress -q $1 ${outfile%.*}.pdf
   echo -n "and png... "
   gs -sDEVICE=png16m -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q \
      -sOutputFile=${1%.ps}.png $outfile
   echo "done."
}

makecpt -T-110/0/0.5 -Crainbow \
   > ./cpts/$(basename ${bathyin%.*}.cpt)

gmtset D_FORMAT=%.0f
psbasemap $parea $proj -Ba10000f5000:"Eastings":/a5000f2500:"Northings":WeSn \
   -Xc -Yc -K > $outfile
grdimage $parea $proj -C./cpts/$(basename ${bathyin%.*}.cpt) \
	$bathyin -I${bathyin%.*}_grad.grd -O -K >> $outfile
gmtset D_FORMAT=%g
gmtset LABEL_FONT_SIZE=14 ANNOT_FONT_SIZE=14
psscale -D56/-3/10/0.5h -I -B20:"Depth (m)": -C./cpts/$(basename ${bathyin%.*}.cpt) -O >> $outfile

formats $outfile
