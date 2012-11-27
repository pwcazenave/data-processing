#!/bin/bash

# Plot the Pacific as a polar projection

export PATH=${PATH//new/GMT4.2.1}

lat=-3
long=-154.5
altitude=30000
tilt=0
azimuth=-15
twist=0
width=0
height=0
proj=-JG${long}/${lat}/${altitude}/${azimuth}/${tilt}/${twist}/${width}/${height}/20c

area=-Rg
ss_bathy=../../smith_and_sandwell/grids/topo_13.1_10min.grd
ss_grad=${ss_bathy%.*}_grad.grd
cpt=./ss_bathy.cpt

outfile=map.ps
#set -eu

formats(){
	if [ $# -eq 0 ]
	then
		echo "Converts PostScript to pdf and png."
		echo "Error: not enough inputs."
		echo "Usage: formats file1.ps [file2.ps] ... [filen.ps]"
	fi
	for i in "$@"
	do
		echo -n "converting $i to pdf "
		ps2pdf -sPAPERSIZE=a4 -dAutoRotatePages=/PageByPage -dPDFSETTINGS=/prepress -q "$i" "${i%.*}.pdf"
		echo -n "and png... "
		gs -sDEVICE=png16m -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q -sOutputFile="${i%.ps}.png" "$i"
		echo "done."
	done
}

gmtset GRID_PEN=1p PAGE_COLOR=black

makecpt -T-7500/-100/100 -Cocean > $cpt

# Make a gradient grid
echo -n "make a gradient grid... "
grdgradient -Ne0.6 -A90 $ss_bathy -G$ss_grad 2> /dev/null
echo "done."
# Add in the S&S gravity derived bathy
echo -n "plot bathy... "
pscoast $area $proj -B0 -Sblue -Dl -K -Xc -Yc -P > $outfile
grdimage $area $proj -B0 -C$cpt $ss_bathy -I$ss_grad -O >> $outfile
echo "done."
# Coastline
#echo -n "add coastline... "
#pscoast $area $proj -B0 -Ggray -Dl -O >> $outfile
#echo "done."
# Grid
#echo -n "add grid lines... "
#psbasemap $area $proj -B30g30 -O >> $outfile
#echo "done."

formats $outfile

rm -f .gmt*
