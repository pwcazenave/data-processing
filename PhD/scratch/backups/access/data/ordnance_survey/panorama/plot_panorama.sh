#!/bin/bash

# Plot the OS panorama data

formats(){
   echo -n "converting to pdf, "
   ps2pdf -sPAPERSIZE=a4 -dAutoRotatePages=/PageByPage -dPDFSETTINGS=/prepress -q $1 ${1%.*}.pdf
   echo -n "png, "
   gs -sDEVICE=png16m -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q \
      -sOutputFile=${1%.ps}.png $1
   echo -n "jpeg, "
   gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q \
      -sOutputFile=${1%.ps}.jpg $1
   echo -n "and png... "
   gs -sDEVICE=png16m -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q \
      -sOutputFile=${1%.ps}.png $1
   echo "done."
}


#xyz2grd -R5550/655600/5400/1220350 -F -I50 panorama_gb.xyz -Gpanorama_gb.grd -V
makecpt -T-1400/1400/10 -Z -V -Cglobe > panorama_gb.cpt
psbasemap -R5550/655600/5400/1220350 -Jx2e-5 -B100000:"Eastings":/100000:"Northings":WeSn -Xc -Yc -K -P -V > panorama_gb.ps
grdimage -R -J -Cpanorama_gb.cpt panorama_gb.grd -O -V >> panorama_gb.ps
formats panorama_gb.ps
