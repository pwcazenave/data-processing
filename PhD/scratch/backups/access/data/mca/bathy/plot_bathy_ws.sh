#!/bin/bash

# script to plot the mca bathy

gmtdefaults -D > .gmtdefaults4

gmtset ANNOT_FONT_SIZE_PRIMARY 12 LABEL_FONT_SIZE 14

gres=1
#ingrd=./grids/mca_western_solent_${gres}m_interp_subset.grd
#ingrd=./grids/ws_${gres}m.grd
ingrd=./grids/ws_${gres}m_blockmean.grd
outfile=./images/ws_${gres}m_bathy.ps

area=$(grdinfo -I1 $ingrd)
#area=-R606925/609043/5618608/5619769
proj=-Jx0.001

if [ ! -d ./images ]; then
   mkdir ./images
fi
if [ ! -d ./cpts ]; then
   mkdir ./cpts
fi

mkgrad(){
   grdgradient ${ingrd} -E250/50 -Nt0.6 \
      -G${ingrd%.*}_grad.grd
}

mkcpt(){
   gmtset D_FORMAT=%g
   makecpt -T0/60/0.1 -Z -I > ./cpts/mca.cpt
#   grd2cpt $area -Cwysiwyg -Z -I -L-100/100 $ingrd \
#     > ./cpts/mca.cpt
}

plot(){
   gmtset D_FORMAT %.0f
   grdimage $area $proj $ingrd -C./cpts/mca.cpt \
      -I${ingrd%.*}_grad.grd \
      -Ba2000f1000:"Eastings":/a2000f1000:"Northings":WeSn -Xc -Y4 -K \
      > $outfile
   gmtset D_FORMAT %g
}

scale(){
   gmtset D_FORMAT %g
   psscale -D10.5/-2/7/0.5h -Ba10f2:,-m::"Depth": -C./cpts/mca.cpt -O >> $outfile
}

formats(){
   ps2pdf -dPDFSETTINGS=/prepress -sPAPERSIZE=a4 "$1" \
      "${1%.ps}.pdf"
   gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE \
      "-sOutputFile=${1%.ps}.jpg" "$1" > /dev/null
}

mkgrad
#mkcpt
plot
scale
formats $outfile

exit 0
