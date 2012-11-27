#!/bin/bash

# script to check that the tidal correction has been applied correctly in caris
# using the tidal gauge data.
#
# the qinsy output has been gridded to 1m using the sounding grid utility.
# the caris data hasn't been gridded at all and needs blockmedianing.

#area=-R314688.00/320332.00/5595452.00/5599112.00
area=-R314695/320327/5595450/5599120
proj=-Jx0.0033

gmtset D_FORMAT %g

caris_in=./raw_data/area473_2007_lines_corrected.txt
qinsy_in=./raw_data/caris_qinsy_comparison.pts
qloud_in=./raw_data/qloud_output.pts
outfile=./images/tidal_check_bathy.ps
#outfile=./images/tidal_check_bathy.ps

# sort the caris data
echo -n "blockmean... "
#blockmedian $area -I1 $caris_in > ${caris_in%.txt}.bmd
#blockmedian $area -I1 $qinsy_in > ${qinsy_in%.pts}.bmd
#blockmedian $area -I1 $qloud_in > ${qloud_in%.pts}.bmd
echo "done."

# make the surfaces
echo -n "surface... "
#surface -Garea473_qinsy_interp.grd -I1 $area -T0.25 ${qinsy_in%.pts}.bmd
#surface -Garea473_qloud_interp.grd -I1 $area -T0.25 ${qloud_in%.pts}.bmd
#surface -Garea473_caris_interp.grd -I1 $area -T0.25 ${caris_in%.txt}.bmd
echo "done."

# clip grids
echo -n "clip the grids... "
#grdmath area473_qinsy_interp.grd area473_2007_mask.grd MUL = area473_qinsy.grd
#grdmath area473_qloud_interp.grd area473_2007_mask.grd MUL = area473_qloud.grd
#grdmath area473_caris_interp.grd area473_2007_mask.grd MUL = area473_caris.grd
echo "done."

# calculate the difference
echo -n "calculate the difference... "
#grdmath area473_qinsy.grd area473_caris.grd SUB = area473_diff.grd
#grdmath area473_qinsy.grd area473_qloud.grd SUB = area473_diff_qinsy_qloud.grd
echo "done."

# plot the images
echo -n "plot the images... "
#makecpt -Crainbow -T-1/1/0.1 -I -Z > diff.cpt
grd2cpt area473_diff.grd -Crainbow $area -Z -I -L-0.2/0.2 \
   > diff.cpt
gmtset D_FORMAT %.0f
grdimage $area $proj -Ba1000f500g1000:"Eastings":/a1000f500g1000:"Northings"::."Difference for Area 473 Swath Bathymetry for 2007":WeSn -Cdiff.cpt area473_diff.grd -K -Xc -Yc > $outfile
gmtset D_FORMAT %.2f
psscale -D19.5/6/5/0.5 -B0.025 -Cdiff.cpt -O -K >> $outfile
pstext $proj $area -O -N << TEXT >> $outfile
320500 5598250 10 0 0 1 Difference (m)
TEXT
echo "done."

echo -n "convert the image to pdf... "
ps2pdf -dPDFSETTINGS=/prepress -sPAPERSIZE=a4 "$outfile" "${outfile%.ps}.pdf"
echo -n "and jpeg... "
gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE \
   "-sOutputFile=${outfile%.ps}.jpg" \
   "$outfile" > /dev/null
echo "done."

#gs -sDEVICE=x11 -sPAPERSIZE=a4 $outfile

exit 0
