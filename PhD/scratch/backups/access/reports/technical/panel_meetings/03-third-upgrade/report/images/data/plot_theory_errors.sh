#!/bin/bash

# script to plot the theoretical errors associated with the fft outputs

gmtset ANNOT_FONT_SIZE_PRIMARY=20 LABEL_FONT_SIZE=20

area=-R-1/1/-1/1
#plotarea=-R-0.1/0.1/-0.1/0.1
plotarea=$area
proj=-JX15

infile=./theorectical_errors.csv
gres=0.01

mkgrd(){
   awk -F"," '{print $1,$2,$3}' $infile | \
      xyz2grd -I$gres $area -G./theory_phiPE.grd
   awk -F"," '{print $1,$2,$4}' $infile | \
      xyz2grd -I$gres $area -G./theory_phiNE.grd
   awk -F"," '{print $1,$2,$3+$4}' $infile | \
      xyz2grd -I$gres $area -G./theory_phiTotal.grd
   awk -F"," '{print $1,$2,$5}' $infile | \
      xyz2grd -I$gres $area -G./theory_lambdaPE.grd
   awk -F"," '{print $1,$2,$6}' $infile | \
      xyz2grd -I$gres $area -G./theory_lambdaNE.grd
   awk -F"," '{print $1,$2,$5+$6}' $infile | \
      xyz2grd -I$gres $area -G./theory_lambdaTotal.grd
}

mkgrd

makecpt -Q -Z -T-1/2/0.1 > phi.cpt
makecpt -Q -Z -T-1/2.5/0.1 > lambda.cpt
#makecpt -Cgray -Q -Z -T0/200/1 > lambda.cpt # does have a massive maximum, but it's a single value at 0, I think.

for i in ./theory_*.grd; do
   whatFile=$(echo $i | cut -c10)
   if [ $whatFile == "p" ]; then
      grdimage -Cphi.cpt $plotarea $proj -Ba0.5f0.1g1:"kx":/a0.5f0.1g1:"ky":WeSn $i -Xc -Yc -K > ${i%.grd}.ps
      psscale -D16.5/7.5/7/0.5 -Ba20f10:"@~\\146@~ (@~\\260@~)": -O -Cphilambda.cpt >> ${i%.grd}.ps
   else
      grdimage -Clambda.cpt $plotarea $proj -Ba0.5f0.1g1:"kx":/a0.5f0.1g1:"ky":WeSn $i -Xc -Yc -K > ${i%.grd}.ps
      psscale -D16.5/7.5/7/0.5 -Ba20f10:"Metres": -O -Cphilambda.cpt >> ${i%.grd}.ps
   fi
done

formats(){
   echo -n "converting $i to pdf "
   ps2pdf -sPAPERSIZE=a4 -dPDFSETTINGS=/prepress -q $1 \
      ${1%.ps}.pdf
   echo -n "and png... "
   gs -sDEVICE=png16m -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q \
      -sOutputFile=${1%.ps}.png $1
   echo "done."
}

for i in ./theory_*.ps; do
   formats $i
done

