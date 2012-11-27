#!/bin/bash

# Script to plot the locations of the Cefas WaveNet buoys.

#waves=./raw_data/WaveNetlocationsicons.csv # WaveNet data
waves=./raw_data/bodc_wave_base_penetration_timing.csv # BODC data

area=-R-17/17/43/67
proj=-Jm0.55c

outfile=./images/$(basename ${0%.*}).ps

infile=/media/z/modelling/data/bathymetry/meshes/round_8_palaeo/ice-5g/rms_calibration/mesh/gebco_00ka_v9.mesh
base=$(basename ${infile%.*})

# Reset GMT setup
gmtdefaults -D > .gmtdefaults4

gmtset BASEMAP_TYPE=plain PLOT_DEGREE_FORMAT=F ANNOT_FONT_SIZE=14 LABEL_FONT_SIZE=14 COLOR_NAN=white

psbasemap $area $proj -Ba5f1/a5f1WeSn -K -X1.5 -Y1 -P > $outfile

# Add the depths and mesh
grdimage $area $proj -Ba5f1/a5f1WeSn ./grids/$base.grd -C./cpts/$base.cpt -K -X1.5c -Y1c -P > $outfile
#psxy $area $proj -m -A ./raw_data/$base.xy -O -K >> $outfile

psscale -D9.3/23.4/6/0.4h -Ba1500f500:"Depth (m) MSL": -O -K -C./cpts/$base.cpt >> $outfile

# Put the coastline in
pscoast $area $proj -Dhigh -Gdarkgrey -W2,black -A50 -N1/2 -N3 -O -K >> $outfile

tmpFile=$(mktemp)
# Extract the relevant columns if we're using the BODC data
if [ $waves == "./raw_data/bodc_wave_base_penetration_timing.csv" ]; then
    awk -F, '{print $3,$2,$5,$6}' $waves > $tmpFile
    waves=$tmpFile
else
    awk -F, '{print $1,$2,$3,$4}' $waves > $tmpFile
    waves=$tmpFile
fi

# Add pie charts for the wave penetration time
makecpt -T0/1/0.01 -Z -Cgray > ./cpts/$(basename ${waves%.*}).cpt
#awk '{if (NR%2==0) print $1,$2,1,100; else print $1,$2,5,5}' $waves | \
while read line; do
    awk '{total=$3+$4; printf "%.2f %.2f %.2f %.2f %.3f %.3f\n%.2f %.2f %.2f %.2f %.3f %.3f\n%.2f %.2f %.2f %.2f %.3f %.3f\n",
        $1,$2,0.1,1.5,0.001,($3/total)*360,
        $1,$2,0.9,1.5,($3/total)*360,(($3/total)*360)+(($4/total)*360),
        $1,$2,0.9,1.5,(($3/total)*360)+(($4/total)*360),360
    }' | \
        psxy $area $proj -O -K -W2,white -SW -C./cpts/$(basename ${waves%.*}).cpt >> $outfile
done < $waves
# Add the first line again; for some reason, it doesn't show up after the
# loop above...
head -1 $waves | \
awk '{total=$3+$4; printf "%.2f %.2f %.2f %.2f %.3f %.3f\n%.2f %.2f %.2f %.2f %.3f %.3f\n%.2f %.2f %.2f %.2f %.3f %.3f\n",
    $1,$2,0.1,1.5,0.001,($3/total)*360,
    $1,$2,0.9,1.5,($3/total)*360,(($3/total)*360)+(($4/total)*360),
    $1,$2,0.9,1.5,(($3/total)*360)+(($4/total)*360),360
}' | \
    psxy $area $proj -O -K -W2,white -SW -C./cpts/$(basename ${waves%.*}).cpt >> $outfile

# Add location points
psxy $area $proj -Sc0.7 -Gwhite -Wblack -O -K $waves >> $outfile

# Add model domain
psxy $area $proj -L -A -W5,black,- -O << DOMAIN >> $outfile
-15 45
-15 65
15 65
15 45
DOMAIN

formats $outfile

#rm -f $tmpFile
