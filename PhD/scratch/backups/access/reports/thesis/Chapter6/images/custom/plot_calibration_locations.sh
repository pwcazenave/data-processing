#!/bin/bash

# Script to plot the locations of the BODC, SHOM, NHS and North Sea Tidal
# Data calibration locations.

# Tides
ntslf=./raw_data/station_locations.csv
nstd=./raw_data/north_sea_tidal_data_proper.csv

# Data I actually used
tides=./raw_data/tide_station_locations.xy

area=-R-17/17/43/67
proj=-Jm0.55

outfile=./images/$(basename ${0%.*}).ps

# Reset GMT setup
gmtdefaults -D > .gmtdefaults4

gmtset BASEMAP_TYPE=plain PLOT_DEGREE_FORMAT=F

# Put the coastline in
psbasemap $area $proj -Ba5f1/a5f1WeSn -K -X1.5 -Y1 -P > $outfile
pscoast $area $proj -Dhigh -Gdarkgrey -W2,black -A50 -N1/2 -N3 -O -K >> $outfile

# Add in the tidal data
awk -F"," '{print $2,$1}' $ntslf | \
    psxy -H1 $area $proj -Sc0.2 -Gblack -O -K >> $outfile
awk -F"," '{print $1,$2}' $nstd | \
    psxy -H1 $area $proj -Sc0.2 -Gblack -O -K >> $outfile

# Add the locations I actually used
psxy -H1 $area $proj -Sc0.2 -Gorange -O -K $tides >> $outfile

# Add model domain
psxy $area $proj -L -A -W5,black,- -O -K << DOMAIN >> $outfile
-15 45
-15 65
15 65
15 45
DOMAIN

# Box around the key
#psxy $area $proj -L -A -Ggray -O -K << KEY >> $outfile
#-13.9 65.7
#-13.9 66.8
#-9 66.8
#-9 65.7
#KEY

# Add a key
#psxy $area $proj -O -K -Sc0.2 -Gblack << SYMBOLS >> $outfile
#-13.5 66.5
#SYMBOLS

#pstext $area $proj -D0.4/-0.15 -O << LABELS >> $outfile
#-13.5 66.5 14 0 0 1 Tides
#LABELS

formats $outfile
psxy -R -J -O -T >> $outfile
mv $outfile ./images/ps/
mv ${outfile%.*}.png ./images/png/
