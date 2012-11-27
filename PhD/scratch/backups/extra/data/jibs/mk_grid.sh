#!/bin/bash

# Script to surface the JIBS data to fill all the little holes

set -eu

west=629667
east=691173
midx=$(echo "scale=0; $west+(($east-$west)/2)" | bc -l)
midx=660771 # optimised version
south=6115744
north=6139699
midy=$(echo "scale=0; $south+(($north-$south)/2)" | bc -l)
midy=6127744 # optimised version
area=-R$west/$east/$south/$north

prefix="jibs_1m"
infile=./raw_data/${prefix}.xyz
gres="-I1"

# Make the grids

# South west
surface -V -T0.25 $gres -R$west/$midx/$south/$midy $infile -G./grids/${prefix}_surface_SW.grd
grdmask -R -NNaN/1/1 -S10 $gres $infile -G./grids/${prefix}_mask_SW.grd
grdmath ./grids/${prefix}_mask_SW.grd ./grids/${prefix}_surface_SW.grd MUL = ./grids/${prefix}_SW.grd
# South east
surface -V -T0.25 $gres -R$midx/$east/$south/$midy $infile -G./grids/${prefix}_surface_SE.grd
grdmask -R -NNaN/1/1 -S10 $gres $infile -G./grids/${prefix}_mask_SE.grd
grdmath ./grids/${prefix}_mask_SE.grd ./grids/${prefix}_surface_SE.grd MUL = ./grids/${prefix}_SE.grd

# North west
surface -V -T0.25 $gres -R$west/$midx/$midy/$north $infile -G./grids/${prefix}_surface_NW.grd
grdmask -R -NNaN/1/1 -S10 $gres $infile -G./grids/${prefix}_mask_NW.grd
grdmath ./grids/${prefix}_mask_NW.grd ./grids/${prefix}_surface_NW.grd MUL = ./grids/${prefix}_NW.grd
# North east
surface -V -T0.25 $gres -R$midx/$east/$midy/$north $infile -G./grids/${prefix}_surface_NE.grd
grdmask -R -NNaN/1/1 -S10 $gres $infile -G./grids/${prefix}_mask_NE.grd
grdmath ./grids/${prefix}_mask_NE.grd ./grids/${prefix}_surface_NE.grd MUL = ./grids/${prefix}_NE.grd


# Combine the grids
grdpaste ./grids/${prefix}_SW.grd ./grids/${prefix}_SE.grd -G./grids/${prefix}_S.grd
grdpaste ./grids/${prefix}_NW.grd ./grids/${prefix}_NE.grd -G./grids/${prefix}_N.grd
grdpaste ./grids/${prefix}_S.grd ./grids/${prefix}_N.grd -G./grids/${prefix}.grd


# Tidy up
#rm -f ./grids/${prefix}_mask_??.grd ./grids/${prefix}_surface_??.grd ./grids/${prefix}_??.grd ./grids/${prefix}_?.grd
