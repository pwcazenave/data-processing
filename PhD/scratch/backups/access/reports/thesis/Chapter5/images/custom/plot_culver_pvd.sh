#!/bin/bash

# Script to plot the two PVDs for the storm and ambient models.

set -eu

inStorm=./raw_Data/csm_culver_v7_Mvar_calib_calibgroup1_HMvar_SM32_d50_280_microns_decoupling_transport_area_storm_pvd_total.csv
inAmbient=./raw_Data/csm_culver_v7_Mvar_calib_calibgroup1_HMvar_SM32_d50_280_microns_decoupling_transport_area_ambient_pvd_total.csv

outfile=./images/culver_sands_storm_ambient_pvd.ps

area=$(cat $inStorm $inAmbient | minmax -I10)
proj=-Jx0.125c

psbasemap $area $proj -Ba20f5:"West-east displacement (m)":/a20f5:"North-south displacement (m)":WeSn \
    -K -Xc -Yc > $outfile
psxy $area $proj $inStorm -O -K -W7,red >> $outfile
awk -F, '{if (NR%3==0) print $1,$2}' $inStorm | \
    psxy $area $proj -O -K -Sc0.15 -Gred >> $outfile
#psxy $area $proj $inAmbient -O -K -W7darkblue >> $outfile
#psxy $area $proj $inAmbient -O -K -Sc0.2 -Gdarkblue >> $outfile

psxy -R -J -O -T >> $outfile
formats $outfile
#mv $outfile ./images/ps
mv ${outfile%.*}.png ./images/png
