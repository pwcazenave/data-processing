#!/bin/bash

# Script to get the zero contour as xyz for the various Peltier
# data sets. 

area=-R-17/17/43/67
gres=10m/11m

formats(){
	echo -n "converting to pdf, "
	ps2pdf -sPAPERSIZE=a4 -dAutoRotatePages=/PageByPage -dPDFSETTINGS=/prepress -q $1 ${outfile%.*}.pdf
	echo -n "png, "
	gs -sDEVICE=png16m -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q \
		-sOutputFile=${1%.ps}.png $outfile
	echo -n "and jpeg... "
	gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q \
		-sOutputFile=${1%.ps}.jpg $outfile
	echo "done."
}

getCoast(){
	xyz2grd $area "$1" -I${gres} -G./grids/$(basename ${1%.csv}.grd)
	grdcontour -Jm1 -A1 -D -m ./grids/$(basename ${1%.csv}.grd) > /dev/null
	if [ -e ./contour ]; then
		awk '{if ($3==0) print $1,$2,$3}' ./contour \
			 > ../../../land_files/round_8_palaeo/peltier/$(basename ${1%.csv}_contour.xyz)
		\rm -f ./contour
	else
		echo "No ice, apparently."
	fi
}

getMask(){
	xyz2grd $area "$1" -I${gres} -G./grids/$(basename ${1%.csv}.grd)
	grdcontour -Jm1 -A1 -D -m ./grids/$(basename ${1%.csv}.grd) > /dev/null
	if [ -e ./contour ]; then
		awk '{if ($3==1) print $1,$2,$3}' ./contour \
			 > ../../../land_files/round_8_palaeo/peltier/$(basename ${1%.csv}_contour.xyz)
		#\rm -f ./contour
	else
		echo "No ice, apparently."
	fi
}

plotCoast(){
	makecpt -Crelief -T-3000/3000/100 > ./cpts/$(basename ${1%.csv}.cpt)
	gmtset BASEMAP_TYPE=plain
	outfile=./images/$(basename ${1%.csv}.ps)
	psbasemap $area -Jm0.5 -Ba10f2/a5f1WeSn -Xc -Yc -K -P > $outfile
	grdimage $area -J -O -K ./grids/$(basename ${1%.csv}.grd) \
		-C./cpts/$(basename ${1%.csv}.cpt) >> $outfile
	grdcontour $area -J -A500 -C250 -S10 \
		./grids/$(basename ${1%.csv}.grd) -O >> $outfile
	formats $outfile
}

subsamplePeltier(){
	tr "," " " < "$1" | subsample - -15 15 45 65 - | tr "," " " \
		> "${1%.csv}_-15_15_45_65.xyz"
	sed -i '1d' "${1%.csv}_-15_15_45_65.xyz"
}

#for file in ./raw_data/ice5g_v1.2_??.?k_10min.csv; do
for file in "$@"; do
#	getCoast $file
	getMask $file
#	plotCoast $file
#	subsamplePeltier $file
done


