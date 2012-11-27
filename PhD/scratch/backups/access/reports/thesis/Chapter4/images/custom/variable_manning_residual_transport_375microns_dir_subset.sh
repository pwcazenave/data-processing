#!/bin/bash

# Script to plot the residual transport analysis results for the 375
# micron sediment with the variable Manning's number roughness.

infile=./raw_data/calibgroup0_HMvar_SM32_d50_375microns_transport_area_residual_bed.csv

area=-R-3.25/3/48.5/51.75
proj=-Jm3

outfile=./images/$(basename ${infile%.*})_dir.ps
base=$(basename ${infile%.*})_subset

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
    scaleIntSub=$(echo "scale=20; $scaleInt/4" | bc -l)

    psbasemap $area $proj -Ba1f0.25/a1f0.25WeSn -K -X1.5 -Y1 -P > $outfile

    # Add the gridded direction results
    makecpt -T-180/180/1 -Ccyclic --COLOR_BACKGROUND=white > ./cpts/${base}_dir.cpt # m3/tide/m

    # Log transform the lengths to fit in properly and make positive for vector
    # symbol.
#    awk -F"," '{if (NR%3==0) print $1,$2,$3,$3,(log($3)/log(10))*-0.01}' $infile | \
#        psxy $area $proj -SVb0.01c/0.05c/0.02cn0.01 -Gblack -O -K -C./cpts/${base}_dir.cpt >> $outfile
    awk -F"," '{print $1,$2,$3}' $infile | \
        pscontour $area $proj -C./cpts/${base}_dir.cpt -I -O -K >> $outfile

    # Mask out the triangulated areas
    awk -F"," '{if ($3!=0) print $1,$2}' $infile | \
        psmask $area $proj -I0.02 -N -S0.11 -Gwhite -O -K >> $outfile
    psmask -C -O -K >> $outfile

    # Put the coastline in
    pscoast $area $proj -Dfull -Gdarkgrey -W5,black -A50 -Cwhite -N1/2 -N3 -O -K >> $outfile
#    pscoast $area $proj -Dfull -Gdarkgrey -W2,black -A50 -N1/2 -N3 -O -K >> $outfile

    # Add model domain
    psxy $area $proj -L -A -W5,black,- -O -K << DOMAIN >> $outfile
    -15 45
    -15 65
    15 65
    15 45
DOMAIN

    psscale -D6/14/6/0.4h -Ba${scaleInt}f${scaleIntSub}:"${varLabel}": -O -K -C./cpts/${base}_dir.cpt >> $outfile

    # Close PostScript
    psxy -R -J -O -T >> $outfile

    formats $outfile
}

# Direction
#mkTri 3
plotMap "Residual direction (@+o@+)" 90
#mkTri 3
#plotMap "Residual direction (@+o@+N)" 0.0005


