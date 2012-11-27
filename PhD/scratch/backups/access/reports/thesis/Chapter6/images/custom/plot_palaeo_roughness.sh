#!/bin/bash

# Plot the model mesh

baseDir=./raw_data/
infiles=(bte0y-00.0k_v5_peltier_seds_M.xyz bte0y-02.0k_v5_peltier_seds_M.xyz bte0y-04.0k_v5_peltier_seds_M.xyz bte0y-06.0k_v5_peltier_seds_M.xyz bte0y-08.0k_v5_peltier_seds_M.xyz)
bathymesh=/media/z/modelling/data/bathymetry/meshes/round_8_palaeo/ice-5g/depth/mesh/bte0y-00.0k_v5_peltier.mesh
area=-R-17/17/43/67
proj=-Jm0.55c

xPosA=(1 0 6.5 -6.5 6.5)
yPosA=(14 -6.5 0 -6.5 0)

figlabel=("A 00.0ka" "B 02.0ka" "C 04.0ka" "D 06.0ka" "E 08.0ka")

base=palaeo_roughness

outfile=./images/$base.ps

set -eu

gmtdefaults -D > .gmtdefaults4

gmtset BASEMAP_TYPE=plain PLOT_DEGREE_FORMAT=F ANNOT_FONT_SIZE=14 LABEL_FONT_SIZE=14 COLOR_NAN=white

mkTri(){
    rawinmesh=$1
    inmesh=$(basename $rawinmesh .xyz)

    # Triangulate the points from the mesh
    awk '{print $2,$3,$1}' $rawinmesh | \
        triangulate $area $proj -I10m -G./grids/${inmesh}_triangle.grd -H1 -m > ./raw_data/$inmesh.xy;
    # Use the bathymetry mesh to mask the land since the roughness is everywhere.
    awk '{if (NF==5 && $4<0) print $2,$3,$4}' $bathymesh | \
        grdmask $area -I10m -S0.3 -NNaN/1/1 -G./grids/${inmesh}_mask.grd
    grdmath ./grids/${inmesh}_mask.grd ./grids/${inmesh}_triangle.grd MUL = ./grids/$inmesh.grd
}


plotMap(){
    xOff=$1
    yOff=$2
    inmesh=$3

#    makecpt $(grdinfo ./grids/$inmesh.grd -T100) -Crainbow -Z > ./cpts/$inmesh.cpt
#    grd2cpt ./grids/$inmesh.grd -L-2000/0 -Crainbow -Z > ./cpts/$inmesh.cpt
    makecpt -T20/100/1 -Crainbow -Z > ./cpts/$inmesh.cpt

    grdimage $area $proj -Ba5f1/a5f1WeSn ./grids/$inmesh.grd -C./cpts/$inmesh.cpt -K -X$xOff -Y$yOff -P > $outfile

    # Add the mesh
#    psxy $area $proj -m -A ./raw_data/$inmesh.xy -O -K >> $outfile
    pscoast $area $proj -Dh -Gdarkgrey -W2,black -A50 -O -K >> $outfile

    # Add axes
    psbasemap $area $proj -Ba5f1/a5f1WeSn -O -K >> $outfile

    psscale -D9.3/23.5/6/0.4h -Ba20f5:"Manning's number (m@+1/3@+s@+-1@+)": -O -K -C./cpts/${infiles[0]%.*}.cpt >> $outfile

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
    # Use the gridded data for this so that the mesh size doesn't bias the
    # distribution.
    grd2xyz -S ./grids/$inmesh.grd | \
        awk '{print $3}' | \
        pshistogram -R20/100/0/10 -JX4.9c/2.3c \
        -Ba20f5:"Manning's number (m@+1/3@+s@+-1@+)":/a5f1:,-%:WeSn \
        -O -Ggray -L1,black -Z1 -W1 -X11.7c -Y3.5c -O -K >> $outfile
}

# Just use one file as they're insufficiently different to make much of a 
# difference
#mkTri ${baseDir}/${infiles[0]}
plotMap 2 c ${infiles[0]%.*}
psxy $area $proj -O -T >> $outfile

formats $outfile
mv $outfile ./images/ps/
mv ${outfile%.*}.png ./images/png/

