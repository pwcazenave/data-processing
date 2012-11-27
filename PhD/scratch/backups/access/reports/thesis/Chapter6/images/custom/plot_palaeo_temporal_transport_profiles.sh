#!/bin/bash

# Script to plot changes in residual transport magnitude from a series of 
# points through the Irish Sea, English Channel and into the North Sea.

area=-R-12/10/47/61
proj=-Jm0.4c
gproj=-JX10c/4.5cl
gproj2=-JX10c/4.5cl

infile=./raw_data/palaeo_residual_points_0-8k.csv
inpc=./raw_data/palaeo_residual_percentages_0-8k.csv
inlocations=./raw_data/palaeo_residual_locations_0-8k.csv
inbathy=/media/z/modelling/data/bathymetry/meshes/round_8_palaeo/ice-5g/depth/mesh/bte0y-00.0k_v5_peltier.mesh

base=palaeo_residual_points
outfile=./images/$base.ps

set -e

gmtdefaults -D > .gmtdefaults4

gmtset BASEMAP_TYPE=plain PLOT_DEGREE_FORMAT=F ANNOT_FONT_SIZE=14 LABEL_FONT_SIZE=14

plotMap(){
    grd=$(basename $inbathy .mesh)
    makecpt -T-500/0/10 -Cgray -Z > ./cpts/${grd}_points.cpt
    makecpt -T0/$(($(wc -l < $infile)-3))/1 -Cwysiwyg -Z > ./cpts/$base.cpt

    grdimage $area $proj -Ba5f1/a5f1WeSn ./grids/$grd.grd -C./cpts/${grd}_points.cpt -K -X2c -Y3c > $outfile

    awk '{if (NF==5 && $4<0) print $2,$3,$4}' $inbathy | \
        psmask $area $proj -I10m -S10m -N -Ggrey -O -K >> $outfile
    psmask -C -O -K >> $outfile

    pscoast $area $proj -Dl -Gdarkgrey -W2,black -A50 -O -K >> $outfile

    psbasemap $area $proj -Ba5f1/a5f1WeSn -O -K >> $outfile

    psxy $area $proj -L -A -W5,black,- -O -K << DOMAIN >> $outfile
    -15 45
    -15 65
    15 65
    15 45
DOMAIN

    # Add the locations in the profile figure
    awk -F, '{print $1,$2,NR,NR}' $inlocations | \
        psxy $area $proj -Sc0.2 -Gwhite -O -K -C./cpts/$base.cpt >> $outfile
    awk -F, '{printf "%.6f %.6f %i %i %i %i %.0f\n", $1,$2,"8","30","0","1",$3}' $inlocations | \
        pstext $area $proj -O -K -D0.3/0 -WwhiteO,white >> $outfile
    
    # Add a label
    pstext $area $proj -O -K -Gwhite << LABEL >> $outfile
    -11.25 60.25 16 0 0 1 A
LABEL
}

plotGraph(){
    timeaxis=0/8000
    yrs=($(seq 0 500 8000))
    garea=-R${timeaxis}/$(awk -F, '{if (NR>1) print $0}' $infile | cut -f2- -d, | tr " " "\n" | minmax -C | awk '{printf "%.10f/%.10f\n", $1*((12*60*60)+(25*60)), $2*((12*60*60)+(25*60))}')
    garea=-R${timeaxis}/0.0000000001/0.1
    sites=($(awk -F, '{print $3}' $inlocations))

    psbasemap $garea $gproj -Ba2000f500:"Years BP":/0wesN -O -K -X10c -Y5.1c >> $outfile
    psbasemap $garea $gproj -B0/a1f3:"Transport (m@+3@+ tide@+-1@+ m@+-1@+)":wEsn --D_FORMAT=%.0e -O -K >> $outfile
    for ((i=0; i<${#sites[@]}; i++)); do
        # Get a line colour
        colour=$(awk '{if (NR=='$(($i+5))') printf "%i/%i/%i\n", ($2+$6)/2,($3+$7)/2,($4+$8)/2}' ./cpts/$base.cpt)
        awk -F, '{if (NR>1) printf "%i %.20f\n", $1,$'$(($i+2))'*((12*60*60)+(25*60))}' $infile | \
            psxy $garea $gproj -W5,$colour -O -K --COLOR_MODEL=RGB >> $outfile
    done
    # Add a label
    pstext $garea $gproj -O -K << LABEL >> $outfile
    200 2e-10 16 0 0 1 B
LABEL

    garea=-R${timeaxis}/0.001/1000

    psbasemap $garea $gproj2 -Ba2000f500:"Years BP":/a1f3:,-%:wESn -O -K -Y-5.1c >> $outfile
    for ((i=0; i<${#sites[@]}; i++)); do
        # Get a line colour
        colour=$(awk '{if (NR=='$(($i+5))') printf "%i/%i/%i\n", ($2+$6)/2,($3+$7)/2,($4+$8)/2}' ./cpts/$base.cpt)
        awk -F, '{print $1,$'$(($i+2))'}' $inpc | \
            psxy $garea $gproj2 -W5,$colour -O -K --COLOR_MODEL=RGB >> $outfile
    done
    # Add a label
    pstext $garea $gproj2 -O -K << LABEL >> $outfile
    200 0.002 16 0 0 1 C
LABEL

}

plotMap
plotGraph
psxy -R -J -T -O >> $outfile
formats $outfile
mv $outfile ./images/ps/
mv ${outfile%.*}.png ./images/png/
