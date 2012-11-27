#!/bin/bash

# Script to plot the residual transport analysis results for the 375
# micron sediment with the variable Manning's number roughness.

infile=./raw_data/calibgroup0_HMvar_SM32_d50_375microns_transport_area_residual_bed.csv

area=-R-17/17/43/67
proj=-Jm0.55

outfile=./images/$(basename ${0%.*}).ps
base=$(basename ${infile%.*})

# Reset GMT setup
gmtdefaults -D > .gmtdefaults4

gmtset BASEMAP_TYPE=plain PLOT_DEGREE_FORMAT=F ANNOT_FONT_SIZE=14 LABEL_FONT_SIZE=14 COLOR_NAN=white

# Triangulate the points from the MATLAB analysis onto a grid,
# discarding the actual triangulation result.
mkTri(){
    colSel=$1
    suffix="$2"
    awk -F, '{print $1,$2,$'$colSel'}' $infile | \
        surface $area -I0.02 -T0.25 -G./grids/${base}_triangle_${suffix}.grd
    awk -F, '{print $1,$2,$'$colSel'}' $infile | \
        grdmask $area -I0.02 -S0.12 -NNaN/1/1 -G./grids/${base}_${suffix}_mask.grd
    grdmath ./grids/${base}_${suffix}_mask.grd ./grids/${base}_triangle_${suffix}.grd MUL = ./grids/${base}_${suffix}.grd
}

plotMap(){
    colRange="$1"
    varLabel="$2"
    scaleInt=$3
    scaleIntSub=$(echo "scale=20; $scaleInt/4" | bc -l)
    psOut="$4"

    psbasemap $area $proj -Ba5f1/a5f1WeSn -K -X1.5 -Y1 -P > $psOut

    # Add the gridded results
    makecpt $colRange $logColour -Crainbow -Z > ./cpts/${base}_dir.cpt
    grdimage $area $proj -Ba5f1/a5f1WeSn ./grids/${base}_dir.grd -C./cpts/${base}_dir.cpt -O -K >> $psOut

    # Put the coastline in
    pscoast $area $proj -Dhigh -Gdarkgrey -W2,black -A50 -N1/2 -N3 -O -K >> $psOut

    # Log transform the lengths to fit in properly and make positive for vector
    # symbol.
#    awk -F"," '{if ($4!=0 && NR%3==0) print $1,$2,$4,$3,(log($4)/log(10))*-0.025}' $infile | \
#        psxy $area $proj -SVb0.01c/0.05c/0.035cn0.01 -Gblack -O -K -C./cpts/${base}.cpt >> $psOut

    # Add model domain
    psxy $area $proj -L -A -W5,black,- -O -K << DOMAIN >> $psOut
    -15 45
    -15 65
    15 65
    15 45
DOMAIN

    psscale -D9.3/23.4/6/0.4h -Ba${scaleInt}f${scaleIntSub}:"${varLabel}": ${logColour/i/} -O -K -C./cpts/${base}.cpt >> $psOut

    # Close PostScript
    psxy -R -J -O -T >> $psOut

    formats $psOut
}

# mkTri <column of interest> <output file suffix>
# plotMap <colour range> <scale label> <scale increment>

# Direction
mkTri 3 dir
plotMap $(grdinfo ./grids/${base}_dir.grd -T10) "Residual direction (@+o@+)" 90 $outfile


