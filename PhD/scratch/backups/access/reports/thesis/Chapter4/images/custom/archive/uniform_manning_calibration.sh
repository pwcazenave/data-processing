#!/bin/bash

# Script to plot the results of the uniform Manning's number models as
# pie charts on a map of the UK.

area=-R-17/17/43/67
proj=-Jm0.55c

outfile=./images/$(basename ${0%.*}).ps

rms=./raw_data/mike_gebco_00ka_v9_M20-M60_2003-01-28_NTSLF-SHOM-NHS_tides_rmsamp_results.csv
std=./raw_data/mike_gebco_00ka_v9_M20-M60_2003-01-28_NTSLF-SHOM-NHS_tides_stdamp_results.csv
lags=./raw_data/mike_gebco_00ka_v9_M20-M60_2003-01-28_NTSLF-SHOM-NHS_tides_phase_results.csv

# Reset GMT setup
gmtdefaults -D > .gmtdefaults4

gmtset BASEMAP_TYPE=plain PLOT_DEGREE_FORMAT=F

# Put the coastline in
psbasemap $area $proj -Ba5f1/a5f1WeSn -K -X1.5 -Y1 -P > $outfile
pscoast $area $proj -Dhigh -Gdarkgrey -W2,black -A50 -N1/2 -N3 -O -K >> $outfile

makecpt -T15/60/1 -Z -I -Cgray > ./cpts/$(basename ${0%.*}).cpt

# Add in the tidal calibration RMS data
while read line; do
    echo $line | \
        awk -F, '!/NaN/ {total=sqrt($3^2)+sqrt($4^2)+sqrt($5^2)+sqrt($6^2)+sqrt($7^2)+sqrt($8^2)+sqrt($9^2)+sqrt($10^2)+sqrt($11^2);
        printf "%.2f %.2f %i %i %.3f %.3f\n%.2f %.2f %i %i %.3f %.3f\n%.2f %.2f %i %i %.3f %.3f\n%.2f %.2f %i %i %.3f %.3f\n%.2f %.2f %i %i %.3f %.3f\n%.2f %.2f %i %i %.3f %.3f\n%.2f %.2f %i %i %.3f %.3f\n%.2f %.2f %i %i %.3f %.3f\n%.2f %.2f %i %i %.3f %.3f\n",
        $1,$2,20,1,0,
            (($3/total)*360),
        $1,$2,25,1,(($3/total)*360),
            (($3/total)*360)+(($4/total)*360),
        $1,$2,32,1,(($3/total)*360)+(($4/total)*360),
            (($3/total)*360)+(($4/total)*360)+(($5/total)*360),
        $1,$2,35,1,(($3/total)*360)+(($4/total)*360)+(($5/total)*360),
            (($3/total)*360)+(($4/total)*360)+(($5/total)*360)+(($6/total)*360),
        $1,$2,40,1,(($3/total)*360)+(($4/total)*360)+(($5/total)*360)+(($6/total)*360),
            (($3/total)*360)+(($4/total)*360)+(($5/total)*360)+(($6/total)*360)+(($7/total)*360),
        $1,$2,45,1,(($3/total)*360)+(($4/total)*360)+(($5/total)*360)+(($6/total)*360)+(($7/total)*360),
            (($3/total)*360)+(($4/total)*360)+(($5/total)*360)+(($6/total)*360)+(($7/total)*360)+(($8/total)*360),
        $1,$2,50,1,(($3/total)*360)+(($4/total)*360)+(($5/total)*360)+(($6/total)*360)+(($7/total)*360)+(($8/total)*360),
            (($3/total)*360)+(($4/total)*360)+(($5/total)*360)+(($6/total)*360)+(($7/total)*360)+(($8/total)*360)+(($9/total)*360),
        $1,$2,55,1,(($3/total)*360)+(($4/total)*360)+(($5/total)*360)+(($6/total)*360)+(($7/total)*360)+(($8/total)*360)+(($9/total)*360),
            (($3/total)*360)+(($4/total)*360)+(($5/total)*360)+(($6/total)*360)+(($7/total)*360)+(($8/total)*360)+(($9/total)*360)+(($10/total)*360),
        $1,$2,60,1,(($3/total)*360)+(($4/total)*360)+(($5/total)*360)+(($6/total)*360)+(($7/total)*360)+(($8/total)*360)+(($9/total)*360)+(($10/total)*360),
            (($3/total)*360)+(($4/total)*360)+(($5/total)*360)+(($6/total)*360)+(($7/total)*360)+(($8/total)*360)+(($9/total)*360)+(($10/total)*360)+(($11/total)*360)
     }' | \
    psxy $area $proj -O -K -SW -C./cpts/$(basename ${0%.*}).cpt >> $outfile
done < $rms

# Add model domain
psxy $area $proj -L -A -W5,black,- -O << DOMAIN >> $outfile
-15 45
-15 65
15 65
15 45
DOMAIN

formats $outfile
