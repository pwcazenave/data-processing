#!/bin/bash

# Script to generate a single .21t file for each years' boundaries.

cd ./generate_palaeo

for i in bte0x-??ka_east.21t; do 
	cat $i \
		${i%_east.21t}_west.21t \
		${i%_east.21t}_south.21t \
		${i%_east.21t}_north.21t \
		> ${i%_east.21t}.21t
done

cd -
