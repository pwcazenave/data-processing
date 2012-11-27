#!/bin/bash

# Script to grid each subset dataset from 2002-2007 (skipping 2006) at their
# best resolution. Output a NetCDF grid in the corresponding year's directory.

gmtdefaults -D > .gmtdefaults4

west=124900
east=125090
south=562130
north=562190
area=-R$west/$east/$south/$north
#area=-R124873/125138/562027/562151
files=(????/*.csv)
gres=(1 0.501/0.503 0.501/0.503 0.501/0.503 0.501/0.503)

for ((i=0; i<${#files[@]}; i++)); do
	yr=$(dirname ${files[i]})
	echo "$yr: ${gres[i]}"
#	tr "," " " < ${files[i]} | \
#		subsample - $west $east $south $north ./${yr}/subsampled/$(basename ${files[i]%.*}_${west}_${east}_${south}_${north}.txt)
	surface $area -I${gres[i]} ./${files[i]} -T0.25 \
		-G./${yr}/subsampled/$(basename ${files[i]%.*}_${west}_${east}_${south}_${north}.grd)
done
