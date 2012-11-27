#!/bin/bash

# script to plot each line for the wreck surveys as an idividual image
# using the lat/long data to create geotiffs would be nice...

utm=./utm
outdir=./images
grids=./grids
gres=-I1
proj=-Jx0.03

for raw in $utm/*.txt; do
   area=$(minmax -I5 $raw)
   xyz2grd $area $gres -G$grids/$(basename $raw .txt).grd $raw -V
   grdgradient -E180/50 -Ne0.7 -G$grids/$(basename $raw .txt)_grad.grd \
      $grids/$(basename $raw .txt).grd -V
   grd2cpt $area $grids/$(basename $raw .txt).grd -Cwysiwyg -Z -V > ./tmp.cpt
   grdimage $area $proj $grids/$(basename $raw .txt).grd \
      -I$grids/$(basename $raw .txt)_grad.grd \
      -B100WeSn -C./tmp.cpt -Xc -Yc -V \
      > $outdir/$(basename $raw .txt).ps
   ps2pdf $outdir/$(basename $raw .txt).ps $outdir/$(basename $raw .txt).pdf
   gs -q -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE \
      -sOutputFile=$outdir/$(basename $raw .txt).jpg \
      $outdir/$(basename $raw .txt).ps \
   \rm ./tmp.cpt
done

exit 0
