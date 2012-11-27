#!/bin/bash
#
# Script to cut a gridded domain into smaller sections specified on the
# command line. Files are output to ./grids/cut/<subset_size>
#
#
# Copyright 2010 Pierre Cazenave <pwc101 {at} soton [dot] ac (dot) uk>
# All rights reserved.
#
# Redistribution and use of this script, with or without modification, is
# permitted provided that the following conditions are met:
#
# 1. Redistributions of this script must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR ''AS IS'' AND ANY EXPRESS OR IMPLIED
# WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
# EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

set -eu

if [ $# -ne 2 ]; then
	echo "$(basename $0): <subset_size> <grid_file>"
	exit 1
fi

gmtdefaults -D > ./.gmtdefaults4

inc=$1
ingrd="$2"
prefix=$(basename "${ingrd%.*}")

area=$(grdinfo -I1 "$ingrd" | sed 's/-R//g')
west=$(echo $area | cut -f1 -d'/')
east=$(echo $area | cut -f2 -d'/')
south=$(echo $area | cut -f3 -d'/')
north=$(echo $area | cut -f4 -d'/')

xiterations_dec=$(echo "scale=0; ($east-$west)/$inc" | bc -l)
yiterations_dec=$(echo "scale=0; ($north-$south)/$inc" | bc -l)
# Round the iterations up
xiterations=$(printf "%.0f" $xiterations_dec)
yiterations=$(printf "%.0f" $yiterations_dec)

if [ ! -d ./splits ]; then
	mkdir ./splits
fi

if [ ! -d ./grids/cut/$inc/ ]; then
	mkdir -p ./grids/cut/$inc
fi

cleanup(){
	for file in "$@"; do
		if [ -e "$file" ]; then
			\rm -f "$file"
		fi
	done
}

mkpoints(){
	if [ -e ./splits/vertical_$inc.txt -o -e ./splits/horizontal_$inc.txt ]; then
		\rm ./splits/vertical_$inc.txt ./splits/horizontal_$inc.txt 2> /dev/null
	fi

	touch ./splits/vertical_$inc.txt
	for ((y=1; y<=$yiterations; y++)); do
		max_y=$(echo "scale=2; $south+$inc" | bc -l)
		echo $south $max_y >> ./splits/vertical_$inc.txt
		south=$max_y
	done

	touch ./splits/horizontal_$inc.txt
	for ((x=1; x<=$xiterations; x++)); do
		max_x=$(echo "scale=2; $west+$inc" | bc -l)
		echo $west $max_x >> ./splits/horizontal_$inc.txt
		west=$max_x
	done

#	\rm ./splits/grid_cut_wesn_$inc.txt
#	touch ./splits/grid_cut_wesn_$inc.txt
#	while read xline; do
#		while read yline; do
#			echo $xline $yline >> ./splits/grid_cut_wesn_$inc.txt
#		done < ./splits/vertical_$inc.txt
#	done < ./splits/horizontal_$inc.txt
}

cutgrid(){
	todo=$(($(wc -l < ./splits/vertical_$inc.txt)*$(wc -l < ./splits/horizontal_$inc.txt)))
	incr=1
	while read xline; do
		while read yline; do
			west=$(echo $xline | cut -f1 -d\ )
			east=$(echo $xline | cut -f2 -d\ )
			south=$(echo $yline | cut -f1 -d\ )
			north=$(echo $yline | cut -f2 -d\ )
			area=-R${west}/${east}/${south}/${north}
			suffix=_${west}_${east}_${south}_${north}

			echo "$incr of $todo: ${prefix}${suffix}.grd"
			incr=$(($incr+1))
			grdcut $area ${ingrd} \
				-G./grids/cut/$inc/${prefix}${suffix}.grd 2> /dev/null
		done < ./splits/vertical_$inc.txt
	done < ./splits/horizontal_$inc.txt

	# Tidy up on our way out...
	cleanup \
		./splits/horizontal_$inc.txt \
		./splits/vertical_$inc.txt \
		./.gmt* \
		./splits/grid_cut_wesn_$inc.txt
	echo "Done."
}

mkpoints
cutgrid

exit 0
