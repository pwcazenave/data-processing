#!/bin/bash

# script to create an interpolated grid of the grain size data

infile=./grain_size.txt
grdfile=./grids/${infile%.*}.grd
outfile=./images/${infile%.*}.ps
bathy=../hsb_plot/grids/all_lines_blockmedian_1m.grd
mask=${bathy%.*}_mask.grd
#mask=../bathy/utec_survey/fourier/grids/all_lines_blockmedian_1m_mask.grd

area=$(grdinfo -I1 $bathy)
gres=$(grdinfo $bathy | grep x_inc | cut -f7 -d' ')
gres=50

surface $area -I$gres $infile -G${grdfile%.*}_interp.grd -T0.25

# Use the existing mask, resampled to $gres
grdsample -I$gres -G${infile%.*}_mask_${gres}m.grd $mask
grdmath ${grdfile%.*}_interp.grd ${infile%.*}_mask_${gres}m.grd \
   MUL = $grdfile
