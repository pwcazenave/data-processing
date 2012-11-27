#!/bin/bash

# script to plot the Radon transform results

gmtset LABEL_FONT_SIZE=18 ANNOT_FONT_SIZE=18
gmtset WANT_EURO_FONT=yes

infile=../synthetic_radon.csv
inres=${infile%.*}_result.csv
instd=${infile%.*}_stddev.csv
outfile=./images/$(basename ${infile%.*}.ps)

area=-R0/180/-284/284
sarea=-R0/180/0/455
proj=-JX24/15
sproj=-JX6/3.75
gres=-I0.1/1

formats(){
   echo -n "converting to pdf "
   ps2pdf -sPAPERSIZE=a4 -dPDFSETTINGS=/prepress -q $1 ${outfile%.*}.pdf
   echo -n "and png... "
   gs -sDEVICE=png16m -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q \
      -sOutputFile=${1%.ps}.png $outfile
   echo "done."
}

process(){
   xyz2grd $area $gres -G./grids/$(basename ${infile%.*}.grd) $infile
}

plot(){
   makecpt $(grdinfo -T1 ./grids/$(basename ${infile%.*}.grd)) \
      -Cgray > ./cpts/$(basename ${infile%.*}.cpt)
   psbasemap $area $proj -Xc -Yc -Ba30f10:"Projected Angle"::,"-@+o@+":/a100f50:"Radon Transform projected coordinate":WSn -K > $outfile
   grdimage $area $proj -O -K -C./cpts/$(basename ${infile%.*}.cpt) \
      ./grids/$(basename ${infile%.*}.grd) >> $outfile
   psxy $area $proj -W8black -O -K << RESULT >> $outfile
   $(head -1 $inres)
   $(tail -1 $inres)
RESULT
   # add in the standard deviation plot
   psxy $sarea $proj -O -W8black,- $instd \
      -Ba30f10:,"-@+o@+":/a100f50:"Standard Deviation":E >> $outfile
}

process
plot
formats $outfile
