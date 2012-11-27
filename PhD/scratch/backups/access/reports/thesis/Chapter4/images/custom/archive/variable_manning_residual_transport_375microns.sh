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
    awk -F, '{print $1,$2,'$colSel'}' $infile | \
        triangulate $area $proj -I0.02 -G./grids/${base}_triangle.grd -H1 -m > /dev/null
    grdmath ./grids/gebco_00ka_v9_mask.grd ./grids/${base}_triangle.grd MUL = ./grids/$base.grd
}

plotMap(){
    varLabel="$1"
    scaleInt=$2
    scaleIntSub=$(echo "scale=2; $scaleInt/4" | bc -l)

    psbasemap $area $proj -Ba5f1/a5f1WeSn -K -X1.5 -Y1 -P > $outfile

    # Add the gridded direction results
    makecpt $(grdinfo ./grids/$base.grd -T100) -Crainbow -Z > ./cpts/$base.cpt
#    makecpt $(awk -F, '{print log($4)/log(10)}' $infile | minmax -T0.1) -Qi -Crainbow -Z > ./cpts/${base}_mag.cpt
    makecpt -T-6.1/-5/0.1 -Crainbow -Z -Qi > ./cpts/${base}_mag.cpt
#    grdimage $area $proj -Ba5f1/a5f1WeSn ./grids/$base.grd -C./cpts/$base.cpt -O -K >> $outfile

    # Put the coastline in
    pscoast $area $proj -Dhigh -Gdarkgrey -W2,black -A50 -N1/2 -N3 -O -K >> $outfile

    # Log transform the lengths to fit in properly and make positive for vector
    # symbol.
    awk -F"," '{if ($4!=0 && NR%3==0) print $1,$2,$4,$3,(log($4)/log(10))*-0.025}' $infile | \
        psxy $area $proj -SVb0.01c/0.05c/0.035cn0.01 -Gblack -O -K -C./cpts/${base}_mag.cpt >> $outfile

    # Add model domain
    psxy $area $proj -L -A -W5,black,- -O -K << DOMAIN >> $outfile
    -15 45
    -15 65
    15 65
    15 45
DOMAIN

    psscale -D9.3/23.4/6/0.4h -Ba${scaleInt}f${scaleIntSub}:"${varLabel}": -Q -O -K -C./cpts/${base}_mag.cpt >> $outfile

    # Close PostScript
    psxy -R -J -O -T >> $outfile

    formats $outfile
}

# Direction
#mkTri 3
plotMap "Residual transport (ms@+-1@+)" 0.0005
#mkTri 3
#plotMap "Residual direction (@+o@+N)" 0.0005


