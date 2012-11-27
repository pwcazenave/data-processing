#!/bin/bash

# Plot the ASTER GDEM analysis histograms for a separate figure

gmtdefaults -D > .gmtdefaults4
gmtset ANNOT_FONT_SIZE=16 LABEL_FONT_SIZE=16 BASEMAP_TYPE=plain COLOR_BACKGROUND=purple        COLOR_FOREGROUND=red

ingrd=./grids/aster_gdem_utm_90m.grd
#ingrd=./grids/aster_gdem_utm_250m.grd

hproj=-JX10c/7c

harea=-R0/120/0/10 # for the results histograms
harea2=-R0/360/0/100 # for the roses
warea=-R1/3.5/0/15 # wavelength
darea=-R0/180/0/30 # orientation
adarea=-R0/360/0/30 # orientation
aarea=-R0/2.5/0/20 # asymmetry
rarea=-R0/15/0/360 # roses
parea=-R0/310000/-20000/60000 # PVDs

outfile=./images/$(basename ${ingrd%.*})_histograms.ps
results=./raw_data/aster_gdem_30000m_subset_results_errors_asymm.csv

set -eu

add_histograms(){
    # Add in the histograms
    # Filter out all values below the nyquist frequency (60m)
    awk -F, '{if ($3>60 && $15==1) print $5}' $results | \
        pshistogram $harea $hproj -W2 -Ggray -L1,gray -K -Z1 \
        -Ba25f5:"Height"::,"-m":/a2f0.5:,"-%":WeSn -X2c -Y12 > $1
    awk -F, '{if ($3>60 && $15==1) print $14}' $results | \
        pshistogram $adarea $hproj -W5 -Ggray -L1,gray -O -K -T0 -Z1 \
        -Ba90f30:"Asymmetry direction"::,"-@+o@+":/a10f2:,"-%":wESn -X12c >> $1
    awk -F, '{if ($3>60 && $15==1) print $3/1000}' $results | \
        pshistogram $warea $hproj -W0.06 -Ggray -L1,gray -O -K -Z1 \
         -Ba0.5f0.1:"Wavelength"::,"-km":/a5f1:,"-%":WeSn -X-12c -Y-10c >> $1
    awk -F, '{if ($3>60 && $15==1) print $19}' $results | \
        pshistogram $aarea $hproj -W0.1 -Ggray -L1,gray -O -K -Z1 \
    -Ba0.5f0.1:"Asymmetry ratio":/a5f1:,"-%":wESn -X12c >> $1
}

add_histograms $outfile
psxy -R -J -T -O >> $outfile
formats $outfile
mv $outfile ./images/ps/
mv ${outfile%.*}.png ./images/png/
