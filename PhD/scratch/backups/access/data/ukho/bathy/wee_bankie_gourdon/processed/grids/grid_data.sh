#!/bin/bash

# Interpolate the data to fill gaps.

set -eu

infile=./raw_data/weeBankie-Gourdon_utm_2m.txt.bz2
baseName=$(basename ${infile%.*})
procArea1=-R524035/558595/6223181/6303181
procArea2=-R558595/593155/6223181/6303181
actualArea=-R524035/592091/6223181/6302687
gres=-I2

pbzcat -p2 $infile | \
	surface $gres $procArea1 -V -T0.25 -G./grids/${baseName}_interp1.grd
pbzcat -p2 $infile | \
	surface $gres $procArea2 -V -T0.25 -G./grids/${baseName}_interp2.grd
	
pbzcat -p2 $infile | \
	grdmask $gres $procArea1 -S6 -NNaN/1/1 -G./grids/${baseName}_mask1.grd
pbzcat -p2 $infile | \
	grdmask $gres $procArea1 -S6 -NNaN/1/1 -G./grids/${baseName}_mask1.grd

grdmath ./grids/${baseName}_interp1.grd ./grids/${baseName}_mask1.grd MUL = \
	./grids/${baseName}_1.grd
grdmath ./grids/${baseName}_interp2.grd ./grids/${baseName}_mask2.grd MUL = \
	./grids/${baseName}_2.grd

grdmerge ./grids/${baseName}_1.grd ./grids/${baseName}_2.grd \
	-G./grids/${baseName}.grd

grdcut $actualArea ./grids/${baseName}.grd -G./grids/${baseName}_cut.grd
