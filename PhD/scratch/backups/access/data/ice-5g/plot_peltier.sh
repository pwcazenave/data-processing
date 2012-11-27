#!/bin/bash

# Script to plot some of the Peltier dat available on his site...

set -eu

gmtset BASEMAP_TYPE=plain

formats(){
	if [ $# -eq 0 ]; then
		echo "Not enough inputs.";
		echo "Usage: formats file1.ps [file2.ps] ... [filen.ps]";
	fi;
	for i in "$@";
	do
		echo -n "converting $i to pdf ";
		ps2pdf -sPAPERSIZE=a4 -dPDFSETTINGS=/prepress -q $i ${i%.*}.pdf;
		echo -n "and png... ";
		gs -sDEVICE=png16m -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q -sOutputFile=${i%.*}.png $i;
		echo "done.";
	done
}

# Use the MATLAB altitude output
indir=/media/e/modelling/data/bathymetry/raw_data/peltier/raw_data

makesensible(){
	# Hack because the data are gridline in longitude but pixel node in latitude.
	xyz2grd $(minmax -I1 "$i") -I10m/10.1m "$i" \
		-G"$infile"
}

plot(){
	#makecpt -T-4000/0/10 -Z -Crainbow > $cpt
	grd2cpt "$infile" -Z -Crainbow > $cpt
	grdimage $area $proj -Ba5f1/a5f1WeSn -Xc -Yc -K -P "$infile" \
		-C./cpts/ice5g_v1.2_00.0k_10min_altitude_-15_15_45_65.cpt \
		> $outfile
	grdcontour $area $proj "$infile" -C500 -A500 -O -K >> $outfile
#		pscoast $area $proj -W -Di -A1000 -Gblack -O >> $outfile
	formats $outfile
}

for i in "$indir"/ice5g_v1.2_??.?k_10min_altitude_-15_15_45_65.xyz; do

	filename=$(basename "${i%.xyz}")
	infile=./grids/"$filename".grd
	outfile=./images/"$filename".ps
	cpt=./cpts/"$filename".cpt

	area=$(minmax -I1 "$i")
	proj=-Jm0.6

	makesensible
	plot

done
