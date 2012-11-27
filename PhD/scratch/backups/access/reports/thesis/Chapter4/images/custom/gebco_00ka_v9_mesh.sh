#!/bin/bash

# Plot the model mesh

infile=../../../../../modelling/data/bathymetry/meshes/round_8_palaeo/ice-5g/rms_calibration/mesh/gebco_00ka_v9.mesh
area=-R-17/17/43/67
proj=-Jm0.55c

base=$(basename ${infile%.*})

outfile=./images/$base.ps

set -eu

gmtdefaults -D > .gmtdefaults4

gmtset BASEMAP_TYPE=plain PLOT_DEGREE_FORMAT=F ANNOT_FONT_SIZE=14 LABEL_FONT_SIZE=14 COLOR_NAN=white

mkTri(){
    # Triangulate the points from the mesh
    awk '{if (NF==5) print $2,$3,$4}' $infile | \
        triangulate $area $proj -I0.02 -G./grids/${base}_triangle.grd -H1 -m > ./raw_data/$base.xy;
    awk '{if (NF==5) print $2,$3,$4}' $infile | \
        grdmask $area -I0.02 -S0.3 -NNaN/1/1 -G./grids/${base}_mask.grd
    grdmath ./grids/${base}_mask.grd ./grids/${base}_triangle.grd MUL = ./grids/$base.grd
}


plotMap(){
    makecpt $(grdinfo ./grids/$base.grd -T100) -Crainbow -Z > ./cpts/$base.cpt

    grdimage $area $proj -Ba5f1/a5f1WeSn ./grids/$base.grd -C./cpts/$base.cpt -K -X1.5c -Y1c -P > $outfile

    # Add the mesh
    psxy $area $proj -m -A ./raw_data/$base.xy -O -K >> $outfile
    pscoast $area $proj -Dhigh -Gdarkgrey -W2,black -A50 -N1/2 -N3 -O -K >> $outfile

    # Add axes
    psbasemap $area $proj -Ba5f1/a5f1WeSn -O -K >> $outfile

    psscale -D9.3/23.4/6/0.4h -Ba1500f500:"Depth (m) MSL": -O -K -C./cpts/$base.cpt >> $outfile

    # Model area
    psxy $area $proj -L -A -W5,black,- -O << DOMAIN >> $outfile
    -15 45
    -15 65
    15 65
    15 45
DOMAIN
}

mkTri
plotMap
formats $outfile

