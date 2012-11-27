#!/bin/bash

# script to determine the ideal bathymetric resolution of a given input file

set -e

# global variables
input=./raw_data/raw_bathy.txt
histogram=./images/stats_histogram.ps
image=./images/stats.ps
h_area=-R0/40/0/20
proj=-Jx0.004
h_proj=-JX11/8
proj_text=-JX22/30
area_text=-R0/22/0/30
gres=-I1
gmtset D_FORMAT %6.2f

# formatting etc
gmtset ANNOT_FONT_SIZE 10
gmtset LABEL_FONT_SIZE 10
gmtset HEADER_FONT_SIZE 12
gmtset ANNOT_FONT_SIZE_SECONDARY 10

# dredge
dge_stats_grid=./dge_stats.grd
dge_xyzstat=./raw_data/dredge_xyzstat.txt
dge_area=-R580000/583500/95000/97500
# 3d dunes
dunes_stats_grid=./dunes_stats.grd
dunes_xyzstat=./raw_data/dunes_xyzstat.txt
dunes_area=-R583000/585000/93500/95500
dunes_proj=-Jx0.0045

echo -n "calculate bins... "
xyz2grd $dge_area $gres $input -An -G$dge_stats_grid
xyz2grd $dunes_area $gres $input -An -G$dunes_stats_grid
echo "done."

echo -n "imaging... "
# dredge
grd2cpt $dge_area $dge_stats_grid -Cwysiwyg -Z > .dge_stats.cpt
gmtset D_FORMAT %6.0f
grdimage $dge_area $proj $dge_stats_grid -C.dge_stats.cpt -K -Xc -Y15 -P \
   -Ba500f250g500:"Eastings":/a500f250g500:"Northings"::."Dredge Area Sounding Density":WeSn \
   > $image
psscale -D15.2/5/5/0.5 -B20 -C.dge_stats.cpt -O -K >> $image
pstext $proj_text $area_text -O -K << TEXT >> $image
15 8 10 0.0 0 1 Soundings
TEXT
# 3d
gmtset D_FORMAT %6.2f
grd2cpt $dunes_area $dunes_stats_grid -Cwysiwyg -Z > .dunes_stats.cpt
gmtset D_FORMAT %6.0f
grdimage $dunes_area $dunes_proj $dunes_stats_grid -C.dunes_stats.cpt -O -K \
   -Ba500f250g500:"Eastings":/a500f250g500:"Northings"::."3D Dunes Area Sounding Density":WeSn\
   -X2.5 -Y-13 >> $image
psscale -D8/4.5/5/0.5 -B10 -C.dunes_stats.cpt -X2 -O -K >> "$image"
pstext $proj_text $area_text -O << TEXT >> $image
8 7.5 10 0.0 0 1 Soundings
TEXT
echo "done."

echo -n "convert bin grid to ascii... "
grd2xyz $dge_area $dge_stats_grid -S > $dge_xyzstat
grd2xyz $dunes_area $dunes_stats_grid -S > $dunes_xyzstat
echo "done."

gmtset D_FORMAT %6.2f

echo -n "imaging... "
# dredge
pshistogram $h_area $h_proj $dge_xyzstat \
   -Ba20f10g20:"Number of raw data points per bin":/a2f1g2:,%::."Dredge grid bin sounding density distribution":WeSn \
   -G200/0/100 -P -L0/0/0 -T2 -W1 -Xc -Y16 -Z1 -K > "$histogram"
# dunes
pshistogram $h_area $h_proj $dunes_xyzstat \
   -Ba20f10g20:"Number of raw data points per bin":/a2f1g2:,%::."3D Dunes grid bin sounding density distribution":WeSn \
   -G0/100/200 -P -L0/0/0 -T2 -W1 -Y-12 -Z1 -O >> "$histogram"
echo -n "conversion... "
ps2pdf -sPAPERSIZE=a4 $histogram ./images/$(basename $histogram .ps).pdf
ps2pdf -sPAPERSIZE=a4 $image ./images/$(basename $image .ps).pdf
gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE \
   -sOutputFile=./images/$(basename $histogram .ps).jpg $histogram \
   > /dev/null
gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE \
   -sOutputFile=./images/$(basename $image .ps).jpg $image > /dev/null
echo "done."
gmtset D_FORMAT %g

exit 0
