#!/bin/bash

# Script to plot the mean and median RMS values for each Manning's run.

proj=-JX11c

outfile=./images/$(basename ${0%.*}).ps

currentsSpeed=(./raw_data/combo_v2_M-1-M60_calibgroup?_speed_best_uni_var_diff_results.csv)
currentsDir=(./raw_data/combo_v2_M-1-M60_calibgroup?_dir_best_uni_var_diff_results.csv)

set -eu

# Reset GMT setup
gmtdefaults -D > .gmtdefaults4

gmtset BASEMAP_TYPE=plain PLOT_DEGREE_FORMAT=F ANNOT_FONT_SIZE=18 LABEL_FONT_SIZE=20

currentsSpeedDiff(){
    west=$(grep -hv NaN ${currentsSpeed[@]} | cut -f4,5 -d, | tr "," "\n" | minmax -C | awk '{print $1}')
    east=$(grep -hv NaN ${currentsSpeed[@]} | cut -f4,5 -d, | tr "," "\n" | minmax -C | awk '{print $2}')
    south=$west
    north=$east
    currentsSpeedArea=-R0/$east/0/$north
    psbasemap $currentsSpeedArea $proj -K -X3.2c -Y2.2 \
        -Ba0.2f0.1:"Variable RMS speed (ms@+-1@+)":/a0.2f0.1:"Uniform RMS speed (ms@+-1@+)":WeSn > $outfile
    cut -f4,5 -d, ${currentsSpeed[@]} | grep -v NaN | tr "," " " | \
        psxy $currentsSpeedArea $proj -O -K -Sc0.15 -Gblack >> $outfile
    printf "%.1f %.10f\n%.1f %.1f\n" 0 0 $east $north | \
        psxy $currentsSpeedArea $proj -O -K -W5,black >> $outfile
}

currentsDirDiff(){
    west=$(grep -hv NaN ${currentsDir[@]} | cut -f4,5 -d, | tr "," "\n" | minmax -C | awk '{print $1}')
    east=$(grep -hv NaN ${currentsDir[@]} | cut -f4,5 -d, | tr "," "\n" | minmax -C | awk '{print $2}')
    south=$west
    north=$east
    currentsDirArea=-R0/$east/0/$north
    psbasemap $currentsDirArea $proj -O -K -X12.5c \
        -Ba20f5:"Variable RMS direction"::,-"@+o@+":/a20f5:"Uniform RMS direction"::,-"@+o@+":wESn >> $outfile
    cut -f4,5 -d, ${currentsDir[@]} | grep -v NaN | tr "," " " | \
        psxy $currentsDirArea $proj -O -K -Sc0.15 -Gblack >> $outfile
    printf "%.1f %.1f\n%.0f %.0f\n" 0 0 $east $north | \
        psxy $currentsDirArea $proj -O -K -W5,black >> $outfile
}

currentsSpeedDiff
currentsDirDiff
psxy -R -J -O -T >> $outfile
formats $outfile


