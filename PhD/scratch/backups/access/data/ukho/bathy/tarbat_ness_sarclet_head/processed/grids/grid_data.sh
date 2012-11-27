#!/bin/bash

# Interpolate the data to fill gaps.

set -eu

infile=./raw_data/tarbatNess-SarcletHead_1m_??.txt.bz2
baseName="tarbatNess-SarcletHead_1m"
procArea1=-R447799/494050/6409549/6470401
procArea2=-R494050/540301/6409549/6470401
actualArea=-R447799/540301/6409549/6470401
gres=-I1

pbzcat -p2 $infile | \
	surface $gres $procArea1 -T0.25 -V -G./grids/${baseName}_interp1.grd
pbzcat -p2 $infile | \
	surface $gres $procArea2 -T0.25 -V -G./grids/${baseName}_interp2.grd
	
pbzcat -p2 $infile | \
	grdmask $gres $procArea1 -S6 -NNaN/1/1 -G./grids/${baseName}_mask1.grd
pbzcat -p2 $infile | \
	grdmask $gres $procArea2 -S6 -NNaN/1/1 -G./grids/${baseName}_mask2.grd

grdmath ./grids/${baseName}_interp1.grd ./grids/${baseName}_mask1.grd MUL = \
	./grids/${baseName}_1.grd
grdmath ./grids/${baseName}_interp2.grd ./grids/${baseName}_mask2.grd MUL = \
	./grids/${baseName}_2.grd

grdmerge ./grids/${baseName}_1.grd ./grids/${baseName}_2.grd \
	-G./grids/${baseName}.grd
	
grdcut $actualArea ./grids/${baseName}.grd -G./grids/${baseName}_cut.grd
