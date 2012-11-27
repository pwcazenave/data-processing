#!/bin/bash

# Plot the model mesh

infile=../../../../../modelling/data/sediment_distribution/round_8_palaeo/ice-5g/rms_calibration/combo_v1_seds_M.mesh
area=-R-17/17/43/67
proj=-Jm0.55c

base=$(basename ${infile%.*})

outfile=./images/$base.ps

set -eu

gmtdefaults -D > .gmtdefaults4

gmtset BASEMAP_TYPE=plain PLOT_DEGREE_FORMAT=F ANNOT_FONT_SIZE=14 LABEL_FONT_SIZE=14 COLOR_NAN=white COLOR_FOREGROUND=255/0/0

mkTri(){
    # Triangulate the points from the mesh
    triangulate $area $proj -I0.02 -G./grids/${base}_triangle.grd -m ./raw_data/$base.xyz > ./raw_data/$base.xy
    grdmask $area -I0.02 -S0.3 -NNaN/1/1 -G./grids/${base}_mask.grd ./raw_data/$base.xyz
    grdmath ./grids/${base}_mask.grd ./grids/${base}_triangle.grd MUL = ./grids/$base.grd
}


plotMap(){
    #makecpt $(grdinfo ./grids/$base.grd -T1) -Crainbow -Z > ./cpts/$base.cpt
#    makecpt -T10/50/1 -Crainbow -Z > ./cpts/$base.cpt

    grdimage $area $proj -Ba5f1/a5f1WeSn ./grids/$base.grd \
         -C./cpts/$base.cpt -K -X1.5c -Y1c -P > $outfile

    # Add the mesh
    psxy $area $proj -m -A ./raw_data/${base%_M}.xy -O -K >> $outfile
    pscoast $area $proj -Dhigh -Gdarkgrey -W2,black -A50 -N1/2 -N3 -O -K >> $outfile

    # Add axes
    psbasemap $area $proj -Ba5f1/a5f1WeSn -O -K >> $outfile

    psscale -D9.3/23.4/6/0.4h -Ba20f5:"Manning's number (m@+1/3@+s@+-1@+)": -O -K -C./cpts/$base.cpt >> $outfile

    # Model area
    psxy $area $proj -L -A -W5,black,- -O -K << DOMAIN >> $outfile
    -15 45
    -15 65
    15 65
    15 45
DOMAIN

    # Histogram of Manning's values
    psxy $area $proj -L -A -Gwhite -O -K << HISTOGRAM >> $outfile
    2.5 46
    2.5 50.7
    13.75 50.7
    13.75 46
HISTOGRAM
    gmtset ANNOT_FONT_SIZE=10 LABEL_FONT_SIZE=10 ANNOT_OFFSET_PRIMARY=0.05c LABEL_OFFSET=0.1c
    awk '{print $3}' ./raw_data/$base.xyz | \
        pshistogram -R0/100/0/12.5 -JX4.9c/2.3c \
        -Ba20f5:"Manning's number (m@+1/3@+s@+-1@+)":/a5f1:,-%:WeSn \
        -O -Ggray -L1,black -Z1 -W1 -X11.7c -Y3.5c >> $outfile
}

#mkTri
plotMap
formats $outfile

