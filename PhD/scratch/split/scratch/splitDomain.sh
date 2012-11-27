#!/bin/bash

# Script to cut the entire domain into smaller sections. I haven't
# yet figured out a way to do this without reading the whole file
# xit*yit times, but there you have it. It should be possible with
# awk, but the if/else statements would be ridiculous. 

set -eu

# Subsampling increment.
inc=$1

# Input data extents.
west=$2
east=$3
south=$4
north=$5

# How many times do we need to read in the file?
xit=$(echo "scale=0; ($east-$west)/$inc" | bc -l)
yit=$(echo "scale=0; ($north-$south)/$inc" | bc -l)
xlims=
ylims=
echo $xit $yit

# Let's make somewhere to put the file
outdir=./$inc
if [ ! -d $outdir ]; then
	mkdir $outdir
fi

infile="$6"

# Counter
c=0

# The business end.
dosample(){
	if [ -e ./gridExtents_${inc}.txt ]; then
		\rm ./gridExtents_${inc}.txt
	fi
	touch ./gridExtents_${inc}.txt

	for ((x=1; x<=$xit; x++)); do
		for ((y=1; y<=$yit; y++)); do
			# Where are we up to?
			c=$(($c+1))
			printf "Iteration %i of %i...\n" $c $(($xit*$yit))

			# Set the maximum extents for this set of iterations.
			max_x=$(echo "scale=2; $west+$inc" | bc -l)
			max_y=$(echo "scale=2; $south+$inc" | bc -l)
			
			# Needs to be unique per iterations
			outfile=$outdir/$(basename ${infile%.*})_${west}_${max_x}_${south}_${max_y}.txt

			echo "subsample $infile $west $max_x $south $max_y $outfile"
			
			# Save the current coordinates in a file.
			echo "$west $max_x $south $max_y" >> ./gridExtents_${inc}.txt

			# Set the current maximum to be the new y minimum.
			west=$max_x
		done
		# Reset the western value at the edge of the domain.
		west=$1
		# Set the current maximum to be the new x minimum.
		south=$max_y
	done
}

# Have to supple the western coordinate to reset it after each
# iteration of the y loop, otherwise it increases beyond the range
# of WESN.
dosample $west

exit 0
