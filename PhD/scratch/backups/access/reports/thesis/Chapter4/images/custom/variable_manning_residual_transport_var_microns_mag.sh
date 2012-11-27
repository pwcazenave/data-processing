#!/bin/bash

# Script to plot the residual transport analysis results for the 375
# micron sediment with the variable Manning's number roughness.

infile=./raw_data/calibgroup0_HMvar_SM32_d50_var_microns_transport_area_residual_bed.csv

area=-R-17/17/43/67
proj=-Jm0.55

outfile=./images/$(basename ${infile%.*})_mag.ps
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
    scaleIntSub=$(echo "scale=20; $scaleInt/4" | bc -l)

    psbasemap $area $proj -Ba5f1/a5f1WeSn -K -X1.5 -Y1 -P > $outfile

    # Add the gridded direction results
    makecpt -T1e-13/0.0001/3 -Crainbow -Qo --COLOR_BACKGROUND=white > ./cpts/${base}_mag.cpt # m3/s/m
#    makecpt -T-20/20/3 -Crainbow -Qi --COLOR_BACKGROUND=white > ./cpts/${base}_mag.cpt # m3/tide/m

    # Log transform the lengths to fit in properly and make positive for vector
    # symbol.
#    awk -F"," '{if (NR%3==0) print $1,$2,$4,$3,(log($4)/log(10))*-0.01}' $infile | \
#        psxy $area $proj -SVb0.01c/0.05c/0.02cn0.01 -Gblack -O -K -C./cpts/${base}_mag.cpt >> $outfile
    awk -F"," '{print $1,$2,$4}' $infile | grep -v -- -inf | \
        pscontour $area $proj -C./cpts/${base}_mag.cpt -I -O -K >> $outfile

    # Mask out the triangulated areas
#    awk -F"," '{if (NR%3==0) print $1,$2,$4,$3,(log($4)/log(10))}' $infile | \
#        psmask $area $proj -I0.02 -O -K -S0.5 >> $outfile
#    psmask $area $proj -C -O -K >> $outfile

    # Put the coastline in
    pscoast $area $proj -Dhigh -Gdarkgrey -W2,black -A50 -Cwhite -N1/2 -N3 -O -K >> $outfile
#    pscoast $area $proj -Dhigh -Gdarkgrey -W2,black -A50 -N1/2 -N3 -O -K >> $outfile

    # Add model domain
    psxy $area $proj -L -A -W5,black,- -O -K << DOMAIN >> $outfile
    -15 45
    -15 65
    15 65
    15 45
DOMAIN

    psscale -D8.5/23.4/13/0.4h -Ba${scaleInt}f${scaleIntSub}:"${varLabel}": \
        -Q -O -K -C./cpts/${base}_mag.cpt --ANNOT_FONT_SIZE=10 >> $outfile

    # Close PostScript
    psxy -R -J -O -T >> $outfile

    formats $outfile
}

# Direction
#mkTri 3
plotMap "Residual transport (m@+3@+s@+-1@+m@+-1@+)" 1
#mkTri 3
#plotMap "Residual direction (@+o@+N)" 0.0005


