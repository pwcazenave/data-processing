#!/bin/bash

# Plot northwestern Europe from space...

#export PATH=${PATH//new/GMT4.2.1}

lat=50
long=-1
altitude=1700
tilt=30
azimuth=-30
twist=0
width=100
height=0
proj=-JG${long}/${lat}/${altitude}/${azimuth}/${tilt}/${twist}/${width}/${height}/25c

area=-Rg
ss_bathy=../smith_and_sandwell/grids/topo_13.1.grd
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

gmtset GRID_PEN=1p PAGE_COLOR=black COLOR_FOREGROUND=blue PAPER_MEDIA=a3

makecpt -T-7500/7500/100 -Cnighttime > $cpt

# Make a gradient grid
echo -n "make a gradient grid... "
if [ ! -e $ss_grad ]; then
	grdgradient -Ne0.6 -A180 $ss_bathy -G$ss_grad 2> /dev/null
fi
echo "done."
# Add in the S&S gravity derived bathy
echo -n "plot bathy... "
pscoast $area $proj -A0/0/10 -B0 -Sblue -Dc -K -Xc -Yc > $outfile
grdimage $area $proj -B0 -C$cpt $ss_bathy -I$ss_grad -O -K >> $outfile
echo "done."
# Coastline
echo -n "add coastline... "
pscoast $area $proj -B0 -Gdarkgray -Df -O >> $outfile
echo "done."
# Grid
#echo -n "add grid lines... "
#psbasemap $area $proj -B30g30 -O >> $outfile
#echo "done."

formats $outfile

rm -f .gmt*
