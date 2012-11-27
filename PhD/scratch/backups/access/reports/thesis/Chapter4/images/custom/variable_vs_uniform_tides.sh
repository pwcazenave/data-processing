#!/bin/bash

# Script to plot the difference between the variable and best uniform
# Manning's models.

proj=-JX11c

outfile=./images/$(basename ${0%.*}).ps

tidesHeight=(./raw_data/combo_v2_2003-01-28_NTSLF-SHOM-NHS_tides_M-1-M60_best_uni_var_diff_results.csv)
tidesOffshore=(./raw_data/calibgroup101_north_sea_points_M-1-M60_best_uni_var_diff_results.csv)

set -eu

# Reset GMT setup
gmtdefaults -D > .gmtdefaults4

gmtset BASEMAP_TYPE=plain PLOT_DEGREE_FORMAT=F ANNOT_FONT_SIZE=18 LABEL_FONT_SIZE=20

tidesHeightDiff(){
    west=$(grep -hv NaN ${tidesHeight[@]} | cut -f4,5 -d, | tr "," "\n" | minmax -C | awk '{print $1}')
    east=$(grep -hv NaN ${tidesHeight[@]} | cut -f4,5 -d, | tr "," "\n" | minmax -C | awk '{print $2}')
    south=$west
    north=$east
    tidesHeightArea=-R0/$east/0/$north
    psbasemap $tidesHeightArea $proj -K -X3.2c -Y2.2 \
        -Ba0.2f0.05:"Variable RMS height"::,-"m":/a0.1f0.05:"Uniform RMS height"::,-"m":WeSn > $outfile
    cut -f4,5 -d, ${tidesHeight[@]} | grep -v NaN | tr "," " " | \
        psxy $tidesHeightArea $proj -O -K -Sc0.15 -Gblack >> $outfile
    printf "%.10f %.10f\n%.1f %.1f\n" 0 0 $east $north | \
        psxy $tidesHeightArea $proj -O -K -W5,black >> $outfile
}

tidesOffshoreDiff(){
    west=$(grep -hv NaN ${tidesOffshore[@]} | cut -f4,5 -d, | tr "," "\n" | minmax -C | awk '{print $1}')
    east=$(grep -hv NaN ${tidesOffshore[@]} | cut -f4,5 -d, | tr "," "\n" | minmax -C | awk '{print $2}')
    south=$west
    north=$east
    tidesOffshoreArea=-R0/$(printf %.1f $east)/0/$(printf %.1f $north)
    psbasemap $tidesOffshoreArea $proj -O -K -X12.5c \
        -Ba0.2f0.05:"Variable RMS height"::,-"m":/a0.1f0.05:"Uniform RMS height"::,-"m":wESn >> $outfile
    cut -f4,5 -d, ${tidesOffshore[@]} | grep -v NaN | tr "," " " | \
        psxy $tidesOffshoreArea $proj -O -K -Sc0.15 -Gblack >> $outfile
    printf "%.10f %.10f\n%.1f %.1f\n" 0 0 $east $north | \
        psxy $tidesOffshoreArea $proj -O -K -W5,black >> $outfile
}

tidesHeightDiff
tidesOffshoreDiff
psxy -R -J -O -T >> $outfile
formats $outfile


