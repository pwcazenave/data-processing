#!/bin/bash

# Script to plot the mean and median RMS values for each Manning's run.

proj=-JX11c/13c

#outfile=./images/$(basename ${0%.*}).ps

version=v5
rmsSpeed=./raw_data/combo_${version}_M20-M60_calibgroup9_currents_averaged_rms_speed_results.csv
stdSpeed=./raw_data/combo_${version}_M20-M60_calibgroup9_currents_averaged_std_speed_results.csv
lagsSpeed=./raw_data/combo_${version}_M20-M60_calibgroup9_currents_averaged_phase_speed_results.csv
rmsDir=./raw_data/combo_${version}_M20-M60_calibgroup9_currents_averaged_rms_direction_results.csv
stdDir=./raw_data/combo_${version}_M20-M60_calibgroup9_currents_averaged_std_direction_results.csv
lagsDir=./raw_data/combo_${version}_M20-M60_calibgroup9_currents_averaged_phase_direction_results.csv

set -eu

# Reset GMT setup
gmtdefaults -D > .gmtdefaults4

gmtset BASEMAP_TYPE=plain PLOT_DEGREE_FORMAT=F ANNOT_FONT_SIZE=18 LABEL_FONT_SIZE=20

ccc-combo(){
    infile=$1
    annotIntRMS=$2
    outfile=./images/$(basename ${1%.*}).ps
    rmsArea=-R${westRMS:-20}/${eastRMS:-60}/${southRMS:-0}/${northRMS:-0.3}
    psbasemap $rmsArea $proj -K -X3.2c -Y2.2 \
        -Ba10f5:"Manning's number (m@+1/3@+s@+-1@+)":/a${annotIntRMS}f$(echo "scale=10; $annotIntRMS/4" | bc -l):"RMS Residual $6"::,"-$5":WeSn \
        > $outfile

#    psxy $rmsArea $proj -O -K -W5,black $infile >> $outfile
#    psxy $rmsArea $proj -O -K -W5,black -Ss0.3 $infile >> $outfile

    cut -f1,3 -d, $infile | \
        psxy $rmsArea $proj -O -K -W5,black >> $outfile
    cut -f1,3 -d, $infile | \
        psxy $rmsArea $proj -O -K -W5,black -St0.3 >> $outfile
    pstext $rmsArea $proj -O -K -N << LABEL >> $outfile
    21 46 20 0 0 1 A
LABEL

    infile=$3
    annotIntPhase=$4
    outfile=./images/$(basename ${1%.*}).ps
    lagsArea=-R${westPhase:-20}/${eastPhase:-60}/${southPhase:--1}/${northPhase:-30}
    psbasemap $lagsArea $proj -O -K -X12.5c \
        -Ba10f5:"Manning's number (m@+1/3@+s@+-1@+)":/a${annotIntPhase}f$(echo "scale=2; $annotIntPhase/4" | bc -l):"Minutes":wESn >> $outfile

#    psxy $lagsArea $proj -O -K -W5,black $infile >> $outfile
#    psxy $lagsArea $proj -O -K -W5,black -Ss0.3 $infile >> $outfile

    cut -f1,3 -d, $infile | \
        psxy $lagsArea $proj -O -K -W5,black >> $outfile
    cut -f1,3 -d, $infile | \
        psxy $lagsArea $proj -O -K -W5,black -St0.3 >> $outfile
    pstext $lagsArea $proj -O -N << LABEL >> $outfile
    21 72 20 0 0 1 B
LABEL
    formats $outfile
}

# Usage of ccc-combo:
# ccc-combo <rmsFileName> <yAxisRMSIncrement> <phaseFileName> <yAxisPhaseIncrement> <dataUnitForAnnotations> <dataUnitForLabel>
ccc-combo $rmsSpeed 0.05 $lagsSpeed 5 " " "(ms@+-1@+)"
southRMS=20 northRMS=45 southPhase=10 northPhase=70 ccc-combo $rmsDir 5 $lagsDir 10 "@+o@+" " "


