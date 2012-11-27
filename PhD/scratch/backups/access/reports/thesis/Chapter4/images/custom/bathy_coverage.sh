#!/bin/bash

# Script to plot the locations of the BODC, SHOM, NHS and North Sea Tidal
# Data calibration locations.

area=-R-17/17/43/67
proj=-Jm0.55

outfile=./images/$(basename ${0%.*}).ps

# Reset GMT setup
gmtdefaults -D > .gmtdefaults4

gmtset BASEMAP_TYPE=plain PLOT_DEGREE_FORMAT=F ANNOT_FONT_SIZE=14 LABEL_FONT_SIZE=16

# Put the coastline in
psbasemap $area $proj -Ba5f1/a5f1WeSn -K -X1.5 -Y1 -P > $outfile

#colours=("p300/1" "p500/23" "p600/19" "p600/17" "p900/12" "p300/10" "p300/13" "p300/44")
colours=("p120/1" "p300/23" "p300/17" "p300/19" "p250/12" "p300/10" "p300/13" "p300/44" "p600/4")
files=(cmap_latlong_points.csv britned_new_points.csv irish_sea_points.csv seazone_combo_points.csv mca_cornwall_points.csv doris_points.csv tarbat_ness_to_sarclet_head_points.csv wee_bankie_to_gourdon_points.csv jibs_points.csv)
names=("C-MAP" "BritNed" "Celtic Sea" "SeaZone" "UKHO HI1059" "DORIS" "UKHO HI1150" "UKHO HI1152" "JIBS")
for ((i=0; i<${#files[@]}; i++)); do
    awk -F, '{print $(NF-1),$NF}' ../../../../../data/arcmap_shapefiles/bathy/${files[i]} | \
        psxy $area $proj -G${colours[i]} -O -K -m >> $outfile
done

xSize=0.75
ySize=0.5
origX=-12
minY=65.15
xOffset=9
yOffset=0.6
# Add in a key
for ((i=0; i<${#files[@]}; i++)); do
    if [ $i -eq 0 -o $i -eq 3 -o $i -eq 6 ]; then
        minX=$origX
    else
        minX=$(echo "scale=2; $minX+$xOffset" | bc -l)
    fi
    if [ $i -lt 3 ]; then # bottom row
        psxy $area $proj -O -K -G${colours[i]} -L << KEY >> $outfile
        $minX $minY
        $(echo "scale=2; $minX+$xSize" | bc -l) $minY
        $(echo "scale=2; $minX+$xSize" | bc -l) $(echo "scale=2; $minY+$ySize" | bc -l)
        $minX $(echo "scale=2; $minY+$ySize" | bc -l)
KEY
    pstext $area $proj -O -K -D0.5/0.15 << LABEL >> $outfile
    $minX $minY 10 0 0 1 ${names[i]}
LABEL
    elif [ $i -ge 3 -a $i -lt 6 ]; then # middle row
        psxy $area $proj -O -K -G${colours[i]} -L << KEY >> $outfile
        $minX $(echo "scale=2; $minY+$yOffset" | bc -l)
        $(echo "scale=2; $minX+$xSize" | bc -l) $(echo "scale=2; $minY+$yOffset" | bc -l)
        $(echo "scale=2; $minX+$xSize" | bc -l) $(echo "scale=2; $minY+$ySize+$yOffset" | bc -l)
        $minX $(echo "scale=2; $minY+$ySize+$yOffset" | bc -l)
KEY
        pstext $area $proj -O -K -D0.5/0.15 << LABEL >> $outfile
        $minX $(echo "scale=2; $minY+$yOffset" | bc -l) 10 0 0 1 ${names[i]}
LABEL
    else # top row
        psxy $area $proj -O -K -G${colours[i]} -L << KEY >> $outfile
        $minX $(echo "scale=2; $minY+(2*$yOffset)" | bc -l)
        $(echo "scale=2; $minX+$xSize" | bc -l) $(echo "scale=2; $minY+(2*$yOffset)" | bc -l)
        $(echo "scale=2; $minX+$xSize" | bc -l) $(echo "scale=2; $minY+$ySize+(2*$yOffset)" | bc -l)
        $minX $(echo "scale=2; $minY+$ySize+(2*$yOffset)" | bc -l)
KEY
        pstext $area $proj -O -K -D0.5/0.15 << LABEL >> $outfile
        $minX $(echo "scale=2; $minY+(2*$yOffset)" | bc -l) 10 0 0 1 ${names[i]}
LABEL
    fi
done

pscoast $area $proj -Dhigh -Gdarkgrey -W2,black -A50 -N1/2 -N3 -O -K >> $outfile

# Add model domain
psxy $area $proj -L -A -W5,black,- -O << DOMAIN >> $outfile
-15 45
-15 65
15 65
15 45
DOMAIN

formats $outfile
