#!/bin/bash

# script to plot the mca bathy

#gmtset ANNOT_FONT_SIZE_PRIMARY 12 LABEL_FONT_SIZE 14
gmtdefaults -D > .gmtdefaults4

gres=1
ingrd=./grids/mca_western_solent_${gres}m.grd
outfile=./images/mca_${gres}m_bathy.ps

area=$(grdinfo -I1 $ingrd)
#area=-R606925/609043/5618608/5619769
proj=-Jx0.001

if [ ! -d ./images ]; then
   mkdir ./images
fi
if [ ! -d ./cpts ]; then
   mkdir ./cpts
fi

mkgrad()
{
   grdgradient ${ingrd} -E250/50 -Nt0.6 \
      -G${ingrd%.*}_grad.grd
}

mkcpt()
{
   gmtset D_FORMAT=%g
   makecpt -T-60/-1/10000 -Z > ./cpts/mca.cpt
#   grd2cpt $area -Cwysiwyg -Z -I $ingrd \
#      > ./cpts/mca.cpt
}

plot()
{
   gmtset D_FORMAT %.0f
   grdimage $area $proj $ingrd -C./cpts/mca.cpt \
      -I${ingrd%.*}_grad.grd \
      -Ba500f100g500:"Eastings":/a500f100g500:"Northings":WeSn -Xc -Yc -K \
      > $outfile
   gmtset D_FORMAT %g
}

scale()
{
   psscale -D10.5/-2/7/0.5h -Ba5000000f1000000:,m::"Depth": -C./cpts/mca.cpt -O >> $outfile
}

formats()
{
   ps2pdf -dPDFSETTINGS=/printer -sPAPERSIZE=a4 "$1" \
      "${1%.ps}.pdf"
   gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE \
      "-sOutputFile=${1%.ps}.jpg" "$1" > /dev/null
}

mkgrad
mkcpt
plot
scale
formats $outfile

exit 0
