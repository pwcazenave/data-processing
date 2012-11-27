#!/bin/bash

# Script to plot the world with the analysis areas in black

proj=-JN26c
area=-Rd
sproj=-JM10c
sarea=-R-12/7/47.5/60

gmtdefaults -D > .gmtdefaults4
gmtset BASEMAP_TYPE=plain

deserts=./raw_data/deserts.xy
desert_labels=./raw_data/desert_labels.xy
outfile=./images/locations.ps

colours=("p300/23" "p300/19" "p250/12" "p300/10" "p300/13" "p300/44" "p600/4")
colours=(black black black black black black black black)
files=(britned_new_points.csv seazone_combo_points.csv mca_cornwall_points.csv doris_points.csv tarbat_ness_to_sarclet_head_points.csv wee_bankie_to_gourdon_points.csv jibs_points.csv)
names=("BritNed" "SeaZone" "UKHO HI1059" "DORIS" "UKHO HI1150" "UKHO HI1152" "JIBS")

pscoast $proj $area -Ba60g30/a30g30 -Xc -Yc -Dl -A10000 -Ggray -W1 -N1 -K > $outfile
psxy $proj $area $deserts -L -m -W4,black -Gblack -O -K >> $outfile
# Add subset map location
psxy $proj $area -L -W6,black -O -K << SUBSET >> $outfile
-12 47.5
-12 60
7 60
7 47.5
SUBSET

# Add subset
psbasemap $sproj $sarea -Bg5/g5 -X-1c -Y5c -Gwhite -O -K >> $outfile
# Add the modified coverage polygons from the modelling chapter
for ((i=0; i<${#files[@]}; i++)); do
    awk -F, '{print $(NF-1),$NF}' \
        ../../../../../data/arcmap_shapefiles/bathy/${files[i]} | \
        psxy $sarea $sproj -G${colours[i]} -H1 -O -K -m >> $outfile
done
# Additional ones (small, so we'll use points)
psxy $sproj $sarea -Ss0.15c -Gwhite -O -K << EXTRAS >> $outfile
0.63 50.789 # HSB
EXTRAS
psxy $sproj $sarea -Ss0.15c -Gblack -O -K << EXTRAS >> $outfile
0.65348 53.276792 # Area 481
EXTRAS
pscoast $sproj $sarea -Bg5/g5 -Df -Ggray -W1 -N1 -O -K >> $outfile
# Add West Solent and Culver over the map.
psxy $sproj $sarea -Ss0.15c -W1,black -Gwhite -O -K << EXTRAS >> $outfile
-3.243794 51.255699 # Culver Sands
-1.447 50.751 # West Solent
EXTRAS



psxy -R -J -T -O >> $outfile
formats $outfile
mv $outfile ./images/ps
mv ${outfile%.*}.png ./images/png
