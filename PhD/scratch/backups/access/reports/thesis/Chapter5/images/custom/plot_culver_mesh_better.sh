#!/bin/bash

# Script to plot the mesh at Culver Sands.

infile=$HOME/modelling/data/bathymetry/meshes/round_10_culver/bank_transport/mesh/csm_culver_v7.mesh

area=-R-3.421/-3.175/51.245/51.325
proj=-Jm100

outfile=./images/$(basename ${infile%.*}).ps
base=$(basename ${infile%.*})

# Reset GMT setup
gmtdefaults -D > .gmtdefaults4

gmtset BASEMAP_TYPE=plain PLOT_DEGREE_FORMAT=F ANNOT_FONT_SIZE=14 LABEL_FONT_SIZE=14 COLOR_NAN=white

# Triangulate the points from the mesh
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
mkTri 3
plotMap "Residual direction (@+o@+)" 90
#mkTri 3
#plotMap "Residual direction (@+o@+N)" 0.0005


