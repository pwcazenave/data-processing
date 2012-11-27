#!/bin/bash

# Since I have no idea where all the plots for the general 
# Hastings bathy are, I'm just going to make a new one.

area=-R578106/588291/91505/98686
proj=-Jx0.0021
bathy=./utec_mask.grd
shading=./utec_grad.grd
cpt=./utec.cpt
outfile=../images/general_bathy.ps

formats(){
   echo -n "converting to pdf "
   ps2pdf -sPAPERSIZE=a4 -dPDFSETTINGS=/prepress -q $1 \
      ${1%.ps}.pdf
   echo -n "and png... "
   gs -sDEVICE=png16m -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q \
      -sOutputFile=${1%.ps}.png $1
   echo "done."
}

#psbasemap $area $proj -Ba2000f500:"Eastings":/a1000f500:"Northings":WeSn \
#   -Xc -Yc -K > $outfile
grdimage $area $proj -Ba2000f500:"Eastings":/a1000f500:"Northings":WeSn \
   $bathy -I$shading -C$cpt -Xc -Yc -K > $outfile
psscale -D22.5/7.5/7/0.5 -B5:"Depth (m)": -C$cpt -O >> $outfile
formats $outfile

