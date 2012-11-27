#!/bin/bash

# script to plot the whole continental shelf bathy at 50m res.

gmtset D_FORMAT=%g
gmtset ANNOT_FONT_SIZE=14
gmtset HEADER_FONT_SIZE=16
gmtset LABEL_FONT_SIZE=16

area=-R408090/783700/5661790/6180540
proj=-Jx0.00004
gres=50

infile=NL-data_MACHU-140508.txt
outfile=./images/$(basename $infile .txt).ps

mkgrid(){
   xyz2grd $area $gres $infile ${infile%.txt}.grd
}

mkgrad(){
   grdgradient -A250/50 -Nt0.7 ${infile%.txt}.grd -G${infile%.txt}_grad.grd
}

mkcpt(){
   makecpt -I -Cwysiwyg -T-15/60/0.1 > ${infile%.txt}.cpt
}

mkplot(){
   gmtset D_FORMAT=%.0f
   grdimage $area $proj -C${infile%.txt}.cpt ${infile%.txt}.grd \
      -Xc -Yc -P \
      -Ba50000f25000g50000:"Eastings":/a50000f25000g50000:"Northings":WeSn \
      -I${infile%.txt}_grad.grd -Q -K \
      > $outfile
   gmtset D_FORMAT=%.2f
   psscale -D7.5/-2/10/0.5h \
      -C${infile%.txt}.cpt -O -Ba20f10:"Depth (m)": \
      >> $outfile
}

formats(){
   echo -n "converting $outfile to pdf "
   ps2pdf -sPAPERSIZE=a4 -dPDFSETTINGS=/prepress "$outfile" "${outfile%.ps}.pdf"
   echo -n "and jpeg... "
   gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q \
      "-sOutputFile=${outfile%.ps}.jpg" \
      "$outfile"
   echo "done."
}

#mkgrid || exit 1
#mkgrad || exit 2
#mkcpt || exit 3
mkplot || exit 4
formats || exit 5

exit 0
