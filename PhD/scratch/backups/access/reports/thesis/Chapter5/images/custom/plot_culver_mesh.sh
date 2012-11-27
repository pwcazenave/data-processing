#!/bin/bash

# Plot the model mesh

infile=$HOME/modelling/data/bathymetry/meshes/round_10_culver/bank_transport/mesh/csm_culver_v7.mesh
area=-R-3.6/-2.95/51.175/51.425
proj=-Jm40

base=$(basename ${infile%.*})

outfile=./images/$base.ps

set -eu

gmtdefaults -D > .gmtdefaults4

gmtset BASEMAP_TYPE=plain PLOT_DEGREE_FORMAT=-DF ANNOT_FONT_SIZE=14 LABEL_FONT_SIZE=14 \
    COLOR_NAN=white PLOT_DEGREE_FORMAT=-DF

mkTri(){
    # Triangulate the points from the mesh
    awk '{if (NF==5) print $2,$3,$4}' $infile | \
        triangulate $area $proj -I0.02 -G./grids/${base}_triangle.grd -H1 -m > ./raw_data/$base.xy;
    awk '{if (NF==5) print $2,$3,$4}' $infile | \
        grdmask $area -I0.02 -S0.3 -NNaN/1/1 -G./grids/${base}_mask.grd
    grdmath ./grids/${base}_mask.grd ./grids/${base}_triangle.grd MUL = ./grids/$base.grd
}


plotMap(){
    makecpt -T-45/0/0.5 -Crainbow > ./cpts/${base}.cpt

    # Add the mesh
    awk  '{if (NF==5) print $2,$3,$4}' $infile | \
        pscontour $area $proj -C./cpts/${base}.cpt -I -K -X2.7c -Y4c > $outfile
    psxy $area $proj -m -A ./raw_data/$base.xy -O -K >> $outfile

    # Add axes
    psbasemap $area $proj -Ba0.1f0.05/a0.05f0.025WeSn -O -K >> $outfile

    # Add a coastline
    pscoast $area $proj -Df -Gdarkgrey -W5,black -Cwhite -N1/2 -N3 -O -K >> $outfile
#    pscoast -Df -R-5.5/-2/50.75/52 -B0 -Jm1.5 --PLOT_DEGREE_FORMAT=-DF -Swhite \
#        -W2 -Na -Ggray -O -K >> $outfile

    psscale -C./cpts/$base.cpt -D13/-1.2/9/0.5h -Ba10f2:"Depth (m)": -O -K >> $outfile
    psxy $area $proj -T -O >> $outfile
}

#mkTri
plotMap
formats $outfile

