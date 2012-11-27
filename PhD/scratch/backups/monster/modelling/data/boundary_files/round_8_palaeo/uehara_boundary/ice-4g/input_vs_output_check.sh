#!/bin/bash

# Check we've generated the right number of output files for the inputs.
# Simply prints out the number of occurrences of .dsf0 in the .21t files
# and the corresponding number of .dfs0 files inthe dfs0 directory.
#
# Pierre Cazenave 14/10/2010 v1.0
#
# Public domain.

names=(west east south north)
for j in {0..12}; do 
	# What year are we doing?
	year=$(printf %02i $j)
	echo "${year}ka BP:"
	for ((i=0; i<${#names[@]}; i++)); do 
		inNum=$(grep -c \.dfs0 generate_palaeo/bta0-${year}ka_${names[i]}.21t)
		outNum=$(ls ./dfs0/bta0-${year}ka_*${names[i]}.dfs0 | wc -l)
		printf "%s:\t%i\t%i\t\t(%i)\n" ${names[i]} $inNum $outNum $(($inNum-$outNum))
	done
done
