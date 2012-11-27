#!/bin/bash

# Script to obtain the position of the edges of the ice coverage for
# use in ArcGIS.

west=-17
east=17
south=43
north=67

area=-R${west}/${east}/${south}/${north}
proj=-Jm1
gres=-I10m/10.1m

for i in ./raw_data/Ice5G_1.2_*KBP_10min_mask.csv; do
	echo -n "Working on $i... "
	workingFile=${i%.*}_${west}_${east}_${south}_${north}.csv
#	tr "," " " < $i | subsample - $west $east $south $north $workingFile
#	xyz2grd $area $gres $workingFile -G./grids/$(basename ${workingFile%.*}.grd)
	grdcontour $area $proj -A1 -D -m ./grids/$(basename ${workingFile%.*}.grd) > /dev/null 2>/dev/null
	if [ ! -e ./contour ]; then
		echo "no ice in the domain."
		continue
	else
		echo "ice!"
		arcSafeFile=${workingFile//1.2/1_2}
		arcSafeFile=${arcSafeFile//.0/_0}
		arcSafeFile=${arcSafeFile//.5/_5}
		echo "lonDD,latDD" > ${arcSafeFile%.*}_arc_contours.csv
		grep -v '>' ./contour | awk '{OFS=","; print $1,$2}' >> ${arcSafeFile%.*}_arc_contours.csv
		\rm -f ./contour
		continue
	fi
done
