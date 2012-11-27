#!/bin/bash

# Script to lowpass filter the Culver Sands bathymetry.

infile=./8148_Culver_2m_UTMZone30_Oct2009.xyz
area=-R473061/485061/5679121/5684241
gres=-I2

# We need to remove all the NaNs for the FFT, so we'll surface the whole area.
# We're doing a lowpass here anyway, so extra long wavelength components (such
# as the surface fringe) aren't too much of a problem, we'll just grdmath them
# out with a mask.
#surface $area $gres $infile -V -T0.25 -G${infile%.*}_surface.grd
grdmask -V -S2 $gres $area -NNaN/1/1 $infile -G${infile%.*}_mask.grd

# Do the fft on the surfaced data
minWavelength=30
maxWavelength=50
#grdfft -L -F-/-/$maxWavelength/$minWavelength -V -G${infile%.*}_surface_lowpass_${maxWavelength}-${minWavelength}.grd \
#	${infile%.*}_surface.grd

# Clip with the mask
grdmath ${infile%.*}_mask.grd ${infile%.*}_surface_lowpass_${maxWavelength}-${minWavelength}.grd \
 MUL = ${infile%.*}_surface_lowpass_${maxWavelength}-${minWavelength}_clip.grd
# Gradient file
grdgradient -V ${infile%.*}_surface_lowpass_${maxWavelength}-${minWavelength}_clip.grd \
	-G${infile%.*}_surface_lowpass_${maxWavelength}-${minWavelength}_grad.grd -A250 -Nt0.7


# Make a quick image
makecpt -V -T3/22/1 -Z -I > test.cpt
grdimage -V -Jx0.002 -Xc -Yc -B1000WeSn -I${infile%.*}_surface_lowpass_${maxWavelength}-${minWavelength}_grad.grd \
	${infile%.*}_surface_lowpass_${maxWavelength}-${minWavelength}_clip.grd -Ctest.cpt > test.ps
