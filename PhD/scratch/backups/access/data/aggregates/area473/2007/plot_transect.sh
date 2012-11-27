#!/bin/bash

# script to plot a transect across the QINSy and CARIS outputs

qinsy=./area473_qinsy.grd
qloud=./area473_qloud.grd
caris=./area473_caris.grd
outfile=./images/mru_check_transect.ps

map_area=-R314695/320327/5595450/5599120
map_proj=-Jx0.0025

# make the transect
project -C314800/5597760 -E319500/5598975 -N -G1 > ./raw_data/mru_check.trk

# take the transects
gmtset D_FORMAT %g
grdtrack ./raw_data/mru_check.trk -G$qinsy -S > ./raw_data/mru_check_qinsy.pfl
grdtrack ./raw_data/mru_check.trk -G$qloud -S > ./raw_data/mru_check_qloud.pfl
grdtrack ./raw_data/mru_check.trk -G$caris -S > ./raw_data/mru_check_caris.pfl

# plot the bathy grid for location
gmtset D_FORMAT %.0f
psbasemap $map_area $map_proj -Ba1000f500g1000:"Eastings":/a1000f500g1000:"Northings"::."Area 473 swath bathymetry for 2007":WeSn -P -Xc -Y17 -K > $outfile
gmtset D_FORMAT %g
makecpt -Crainbow -T41/49/0.1 -I -Z > bathy.cpt
cpt=-C./bathy.cpt
grdimage $map_area $map_proj $cpt $caris -Bg1000 -O -K >> $outfile
psscale -D15/4.5/-4/0.3 -B1 $cpt -O -K >> $outfile
pstext $map_proj $map_area -O -K -N << TEXT >> $outfile
320650 5598250 10 0 0 1 Depth (m)
TEXT

# plot the profile location
psxy $map_area $map_proj -W7/0/0/0 -O -K ./raw_data/mru_check_caris.pfl \
   >> $outfile
start=$(head -n1 ./raw_data/mru_check_caris.pfl | awk '{print $1,$2}')
end=$(tail -n1 ./raw_data/mru_check_caris.pfl | awk '{print $1,$2}')
pstext $map_area $map_proj -O -K -N -D-0.2/-0.4 << START_END >> $outfile
$start 10 1 0 1 A
$end 10 1 0 1 A'
START_END

# plot the profiles
gmtset D_FORMAT %g
plot_area=$(cat ./raw_data/mru_*.pfl | awk '{print $3,$4}' | minmax -I500/0.5)
plot_proj=-JX16/-10
# caris profile
awk '{print $3,$4}' ./raw_data/mru_check_caris.pfl | \
   psxy $plot_area $plot_proj -O -K \
   -Ba500f250g500:"Distance along line A-A' (m)":/a1f0.5g1:"Depth (m)"::."Depth profile A-A' (red = caris, blue = qinsy, green = qloud)":WeSn \
   -X-1 -Y-14 -W1/200/0/100 >> $outfile
# qinsy profile
awk '{print $3,$4}' ./raw_data/mru_check_qinsy.pfl | \
   psxy $plot_area $plot_proj -O -K \
   -B0 -W1/0/100/200 >> $outfile
# qloud profile
awk '{print $3,$4}' ./raw_data/mru_check_qloud.pfl | \
   psxy $plot_area $plot_proj -O -K \
   -B0 -W1/0/200/100 >> $outfile

echo -n "convert the image to pdf... "
ps2pdf -dPDFSETTINGS=/prepress -sPAPERSIZE=a4 "$outfile" "${outfile%.ps}.pdf" \
   &> /dev/null
echo -n "and jpeg... "
gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE \
   "-sOutputFile=${outfile%.ps}.jpg" \
   "$outfile" &> /dev/null
echo "done."

exit 0

