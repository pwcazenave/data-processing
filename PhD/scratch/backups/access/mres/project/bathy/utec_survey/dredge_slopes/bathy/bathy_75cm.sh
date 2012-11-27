#!/bin/bash

##!! script needs to be run on nemo!

# script to plot the hastings bathy at 50cm resolution

set -e

gmtset D_FORMAT %6.2f

# global
proj=-Jx0.0007
gres=-I0.75
infile=./raw_data/raw_bathy.txt
outfile=./images/50cm_bathy.ps
prefix=75cm_bathy

# whole area 
area=-R578106/588291/91503/98688
# split area
sw_area=-R578106/583198.5/91503/95095.5
se_area=-R583198.5/588291/91503/95095.5
nw_area=-R578106/583198.5/95095.5/98688
ne_area=-R583198.5/588291/95095.5/98688

echo -n "blockmeaning... "
#blockmean $area $gres $infile > ./raw_data/"$prefix".bmd
echo -n "1 "
blockmean $sw_area $gres $infile > ./raw_data/"$prefix"_sw.bmd
echo -n "2 "
blockmean $se_area $gres $infile > ./raw_data/"$prefix"_se.bmd
echo -n "3 "
blockmean $nw_area $gres $infile > ./raw_data/"$prefix"_nw.bmd
echo -n "4 "
blockmean $ne_area $gres $infile > ./raw_data/"$prefix"_ne.bmd
echo "done."

echo -n "surfacing... "
#surface $area $gres -T0.25 -G"$prefix"_surface.grd -S2 \
#   ./raw_data/"$prefix".bmd
surface $sw_area $gres -T0.25 -G"$prefix"_sw_surface.grd \
   ./raw_data/"$prefix"_sw.bmd
surface $se_area $gres -T0.25 -G"$prefix"_se_surface.grd \
   ./raw_data/"$prefix"_se.bmd
surface $nw_area $gres -T0.25 -G"$prefix"_nw_surface.grd \
   ./raw_data/"$prefix"_nw.bmd
surface $ne_area $gres -T0.25 -G"$prefix"_ne_surface.grd \
   ./raw_data/"$prefix"_ne.bmd
echo "done."

#echo "merging the four surfaces into one grid file... "
echo -n "south... "
grdpaste "$prefix"_sw_surface.grd "$prefix"_se_surface.grd \
   -G"$prefix"_s_surface.grd
echo "done."
echo -n "north... "
grdpaste "$prefix"_nw_surface.grd "$prefix"_ne_surface.grd \
   -G"$prefix"_n_surface.grd
echo "done." 
echo -n "combine north and south... "
grdpaste "$prefix"_n_surface.grd "$prefix"_s_surface.grd \
   -G"$prefix"_surface.grd
\rm -f "$prefix"_s_surface.grd "$prefix"_n_surface.grd

echo -n "gradient... "
grdgradient ./"$prefix"_surface.grd -A250 \
   -Nt0.7 -G"$prefix"_grad.grd
echo -n "masking... "
grdmask $area $infile \
   -G./"$prefix"_mask.grd $gres -N/NaN/1/1 -S2
grdmath ./"$prefix"_surface.grd \
   ./"$prefix"_mask.grd \
   MUL = ./"$prefix"_final.grd
echo -n "imaging... "
grdimage $area $proj ./"$prefix"_final.grd -Bf1000a500g1000WeSn\
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
