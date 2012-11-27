#!/bin/bash

# Script to plot the mean and median RMS values for each Manning's run.

rmsArea=-R5/60/0/1
lagsArea=-R5/60/-2/80
proj=-JX11c/13c

outfile=./images/$(basename ${0%.*}).ps

#rms=./raw_data/mike_gebco_00ka_v9_M5-M60_2003-01-28_NTSLF-SHOM-NHS_tides_averaged_rms_results.csv
#std=./raw_data/mike_gebco_00ka_v9_M5-M60_2003-01-28_NTSLF-SHOM-NHS_tides_averaged_std_results.csv
#lags=./raw_data/mike_gebco_00ka_v9_M5-M60_2003-01-28_NTSLF-SHOM-NHS_tides_averaged_phase_results.csv
# Use the (manually calculated) averages for the combined BODC and North Sea
# Tidal Data results (from raw data (i.e. *{phase,rmsamp,stdamp}_results.csv)).
rms=./raw_data/combined_tidal_averaged_rms_results.csv
std=./raw_data/combined_tidal_averaged_std_results.csv
lags=./raw_data/combined_tidal_averaged_phase_results.csv

set -eu

# Reset GMT setup
gmtdefaults -D > .gmtdefaults4

gmtset BASEMAP_TYPE=plain PLOT_DEGREE_FORMAT=F ANNOT_FONT_SIZE=18 LABEL_FONT_SIZE=20

rmsRes(){
    psbasemap $rmsArea $proj -K -X3.2c -Y2.2 \
        -Ba10f5:"Manning's number (m@+1/3@+s@+-1@+)":/a0.1f0.02:"RMS Residual"::,"-m":WeSn > $outfile

    psxy $rmsArea $proj -O -K -W5,black $rms >> $outfile
    psxy $rmsArea $proj -O -K -W5,black -Ss0.3 $rms >> $outfile

    cut -f1,3 -d, $rms | \
        psxy $rmsArea $proj -O -K -W5,black >> $outfile
    cut -f1,3 -d, $rms | \
        psxy $rmsArea $proj -O -K -W5,black -St0.3 >> $outfile
    pstext $rmsArea $proj -O -K -N << LABEL >> $outfile
    5 1.02 20 0 0 1 A
LABEL
}

lagsRes(){
    psbasemap $lagsArea $proj -O -K -X12.5c \
        -Ba10f5:"Manning's number (m@+1/3@+s@+-1@+)":/a10f2:"Minutes":wESn >> $outfile

    psxy $lagsArea $proj -O -K -W5,black $lags >> $outfile
    psxy $lagsArea $proj -O -K -W5,black -Ss0.3 $lags >> $outfile

    cut -f1,3 -d, $lags | \
        psxy $lagsArea $proj -O -K -W5,black >> $outfile
    cut -f1,3 -d, $lags | \
        psxy $lagsArea $proj -O -K -W5,black -St0.3 >> $outfile
    pstext $lagsArea $proj -O -N << LABEL >> $outfile
    5 81.5 20 0 0 1 B
LABEL
}

rmsRes
lagsRes
formats $outfile


