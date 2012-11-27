#!/bin/bash

# script to plot the subset of the hastings bathy

set -e

gmtset D_FORMAT %6.2f

# global
proj=-Jx0.007
gres=-I0.5
infile=./raw_data/raw_bathy.txt

# 3d dunes
area=-R583000/585000/93500/95500
outfile=./images/3d_dunes.ps
prefix=3d_dunes

echo -n "blockmeaning... "
blockmean $area $gres $infile > ./raw_data/"$prefix".bmd
echo "done."

echo -n "surfacing... "
surface $area $gres -T0.25 -G"$prefix"_surface.grd ./raw_data/"$prefix".bmd
echo "done."

echo -n "gradient... "
grdgradient ./"$prefix"_surface.grd -A250 \
   -Nt0.7 -G"$prefix"_grad.grd
echo -n "masking... "
grdmask $area $infile \
   -G./"$prefix"_mask.grd $gres -N/NaN/1/1 -S1
grdmath ./"$prefix"_surface.grd \
   ./"$prefix"_mask.grd \
   MUL = ./"$prefix"_final.grd
echo -n "imaging... "
grdimage $area $proj ./"$prefix"_final.grd -Bf200a200g200WeSn\
   -Cutec.cpt -I./"$prefix"_grad.grd > $outfile
echo "done."

echo -n "conversion... "
ps2pdf -r300 -sPAPERSIZE=a4 "$outfile" \
   "./images/$(basename "$outfile" .ps).pdf"
gs -sDEVICE=jpeg -r1200 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE \
   "-sOutputFile=./images/$(basename "$outfile" .ps).jpg" \
   "$outfile" > /dev/null
echo -n "display... "
#gs -sPAPERSIZE=a4 $outfile
echo "done."   

gmtset D_FORMAT %g

exit 0
