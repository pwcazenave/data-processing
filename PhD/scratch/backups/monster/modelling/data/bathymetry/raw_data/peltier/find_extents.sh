#!/bin/bash

# Script to find the extents of the palaeo coastlines along the model
# boundaries. Uses a series of 4 profiles through a mask composed of
# zeros and ones. When the difference at a given point along the profile
# is non-zero, then we're at a land boundary, and we output the values 
# to a csv file.

export PATH=${PATH/\/new\//\/GMT4.1.4\/}

set -e

formats(){
	if [ $# -eq 0 ]; then
        echo "Converts PostScript to pdf and png."
        echo "Error: not enough inputs."
        echo "Usage: formats file1.ps [file2.ps] ... [filen.ps]"
    fi
    for i in "$@"; do
        echo -n "converting $i to pdf "
        ps2pdf -sPAPERSIZE=a4 -dAutoRotatePages=/PageByPage -dPDFSETTINGS=/prepress -q "$i" "${i%.*}.pdf"
        echo -n "and png... "
        gs -sDEVICE=png16m -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q -sOutputFile="${i%.ps}.png" "$i"
        echo "done."
    done
}

mk_masks(){
	for i in ./raw_data/ice5g_v1.2_??.?k_10min_altitude_-15_15_45_65_subzero.xyz; do
		grdmask -G./grids/$(basename "${i%.xyz}"_mask.grd) -S0.01k -F \
			-I10.5m/10m -R-15/15/45/65 -NNaN/0/1 "$i"
	done
}

plot_masks(){
	makecpt -T0/1/0.1 -Z > ./mask.cpt
	for i in ./grids/ice5g_v1.2_??.?k_10min_altitude_-15_15_45_65_subzero_mask.grd; do
		grdimage "$i" -R-16/16/44/66 -Jm0.5 -Xc -Yc -C./mask.cpt -P > ./images/$(basename "${i%.*}.ps")
	done
	formats ./images/ice5g_v1.2_??.?k_10min_altitude_-15_15_45_65_subzero_mask.ps
}

mk_profiles(){
	inc=$(echo "scale=6; 1/6" | bc -l)
	project -C-15/45 -E-15/65 -G$inc -N > ./profiles/west_project.xy
	project -C15/45 -E15/65 -G$inc -N > ./profiles/east_project.xy
	project -C-15/45 -E15/45 -G$inc -N > ./profiles/south_project.xy
	project -C-15/65 -E15/65 -G$inc -N > ./profiles/north_project.xy
}

mk_sample(){
	for i in ./grids/ice5g_v1.2_??.?k_10min_altitude_-15_15_45_65_subzero_mask.grd; do
		year=$(echo "$i" | cut -f3 -d_)
		for j in ./profiles/*.xy; do
			boundary=$(echo "$j" | cut -f1 -d_ | cut -f3 -d/)
			grdtrack "$j" -G"$i" -S > ./profiles/${year}_${boundary}_sampled.xyz
		done
	done
}

mk_masks
plot_masks
mk_profiles
mk_sample
