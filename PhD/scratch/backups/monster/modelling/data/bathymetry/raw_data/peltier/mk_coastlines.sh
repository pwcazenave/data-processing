#!/bin/bash

# Script to get the zero contour as xyz for the various Peltier
# data sets. 

west=-17
east=17
south=43
north=67
area=-R$west/$east/$south/$north
gres=10m/10.1m

set -eu

formats(){
	echo -n "converting to pdf, "
	ps2pdf -sPAPERSIZE=a4 -dAutoRotatePages=/PageByPage -dPDFSETTINGS=/prepress -q "$1" "${outfile%.*}.pdf"
	echo -n "png, "
	gs -sDEVICE=png16m -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q \
		-sOutputFile="${1%.ps}.png" "$outfile"
	echo -n "and jpeg... "
	gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q \
		-sOutputFile="${1%.ps}.jpg" "$outfile"
	echo "done."
}

getCoast(){
	xyz2grd $area "$1" -I${gres} -G./grids/$(basename ${1%.*}.grd)
	grdcontour $area -Jm1 -A1000 -D -m ./grids/$(basename ${1%.*}.grd) > /dev/null
	if [ -e ./contour ]; then
		awk '{if ($3==0) print $1,$2,$3}' ./contour \
			 > ../../../land_files/round_8_palaeo/peltier/$(basename ${1%.*}_contour.xyz)
		\rm -f ./contour
	else
		echo "No."
	fi
}

plotCoast(){
	makecpt -Crelief -T-3000/3000/100 > ./cpts/$(basename ${1%.*}.cpt)
	gmtset BASEMAP_TYPE=plain
	outfile=./images/$(basename ${1%.*}.ps)
	psbasemap $area -Jm0.5 -Ba10f2/a5f1WeSn -Xc -Yc -K -P > "$outfile"
	grdimage $area -J -O -K ./grids/$(basename ${1%.*}.grd) \
		-C./cpts/$(basename ${1%.*}.cpt) >> "$outfile"
	grdcontour $area -J -A500 -C250 -S10 \
		./grids/$(basename ${1%.*}.grd) -O >> "$outfile"
	formats "$outfile"
}

subsamplePeltier(){
	tr "," " " < "$1" | subsample - $west $east $south $north - | tr "," " " \
		> "${1%.*}_${west}_${east}_${south}_${north}.xyz"
	sed -i '1d' "${1%.*}_${west}_${east}_${south}_${north}.xyz"
}

subZeroPeltier(){
	awk '{if ($3<=0) print $1,$2,$3}' "$1" \
		> ../../../bathymetry/raw_data/peltier/raw_data/$(basename ${1%.*}_subzero.xyz)
}

#for file in ./raw_data/ice5g_v1.2_??.?k_10min.csv; do
for file in "$@"; do

	outFile="${file%.*}_${west}_${east}_${south}_${north}.xyz"

	# Have to run subsamplePeltier first.

	echo -n "Working on $file... "
	if [ ! -e "$outFile" ]; then
		subsamplePeltier "$file"
	fi

	if [ ! -e "$outFile" ]; then
		echo "Run subsamplePeltier() on $file first."
		continue
	else
		getCoast "$outFile"
		subZeroPeltier "$outFile"
		plotCoast "$outFile"
	fi
	echo "done."
done


