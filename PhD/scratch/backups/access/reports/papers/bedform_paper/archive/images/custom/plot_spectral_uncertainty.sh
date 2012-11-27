#!/bin/bash

# Plot the output of acquisition_spectral_uncertainty.m for the paper.

gmtdefaults -D > .gmtdefaults4

gmtset LABEL_FONT_SIZE=16

infile=./raw_data/spectral_uncertainty.csv
outfile=./images/$(basename ${infile%.*}).ps
area=$(minmax -I1/1e-7 $infile)
proj=-JX23l/15l

# y axis
gmtset D_FORMAT=%.6f
psbasemap $area $proj \
    -Ba1f3:"Wavelength (m)":/a1f3:"Acquisition spectral uncertainty (m@+-1@+)":Wesn \
    -K -X5 -Yc > $outfile
# x axis
gmtset D_FORMAT=%lg
psbasemap $area $proj \
    -Ba1f3:"Wavelength (m)":/a1f3:"Acquisition spectral uncertainty (m@+-1@+)":weSn \
    -O -K >> $outfile
psxy $area $proj $infile -W5,black -O -K >> $outfile
    psxy $area $proj $infile -W5 -Sc0.25 -O >> $outfile

formats $outfile
