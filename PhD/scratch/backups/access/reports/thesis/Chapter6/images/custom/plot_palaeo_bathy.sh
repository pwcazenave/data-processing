#!/bin/bash

# Plot the model mesh

baseDir=/media/z/modelling/data/bathymetry/meshes/round_8_palaeo/ice-5g/depth/mesh/
infiles=(bte0y-00.0k_v5_peltier.mesh bte0y-02.0k_v5_peltier.mesh bte0y-04.0k_v5_peltier.mesh bte0y-06.0k_v5_peltier.mesh bte0y-08.0k_v5_peltier.mesh)
area=-R-12/10/47/61
proj=-Jm0.24c

xPosA=(1 0 7 -7 7)
yPosA=(15 -7 0 -7 0)

figlabel=("A 00.0ka" "B 02.0ka" "C 04.0ka" "D 06.0ka" "E 08.0ka")

base=palaeo_bathy_panels

outfile=./images/$base.ps

set -eu

gmtdefaults -D > .gmtdefaults4

gmtset BASEMAP_TYPE=plain PLOT_DEGREE_FORMAT=F ANNOT_FONT_SIZE=11 LABEL_FONT_SIZE=11 COLOR_NAN=white

mkTri(){
    rawinmesh=$1
    inmesh=$(basename $rawinmesh .mesh)

    # Triangulate the points from the mesh
    awk '{if (NF==5 && $4<0) print $2,$3,$4}' $rawinmesh | \
        triangulate $area $proj -I10m -G./grids/${inmesh}_triangle.grd -H1 -m > ./raw_data/$inmesh.xy;
    awk '{if (NF==5 && $4<0) print $2,$3,$4}' $rawinmesh | \
        grdmask $area -I10m -S0.3 -NNaN/1/1 -G./grids/${inmesh}_mask.grd
    grdmath ./grids/${inmesh}_mask.grd ./grids/${inmesh}_triangle.grd MUL = ./grids/$inmesh.grd
}


plotMap(){
    xOff=$1
    yOff=$2
    inmesh=$3
    textlabel="$4"

#    makecpt $(grdinfo ./grids/$inmesh.grd -T100) -Crainbow -Z > ./cpts/$inmesh.cpt
#    grd2cpt ./grids/$inmesh.grd -L-2000/0 -Crainbow -Z > ./cpts/$inmesh.cpt
    makecpt -T-500/0/10 -Crainbow -Z > ./cpts/$inmesh.cpt

    grdimage $area $proj -Ba5f1/a5f1WeSn ./grids/$inmesh.grd -C./cpts/$inmesh.cpt -O -K -X$xOff -Y$yOff >> $outfile

    # Add the mesh
#    psxy $area $proj -m -A ./raw_data/$inmesh.xy -O -K >> $outfile
    grep -v Edge ./raw_data/$inmesh.xy | \
        psmask $area $proj -I10m -S10m -N -Ggrey -O -K >> $outfile
    psmask -C -O -K >> $outfile
    pscoast $area $proj -Dl -Gdarkgrey -W2,black -A50 -O -K >> $outfile
    cat << CONTS > ./raw_data/contours.txt
-30 A
-50 A
-70 A
-100 A
-200 A
CONTS
    grdcontour $area $proj -C30 -Wa1 -A30+s6+gwhite+o -S50 -L-200/10 ./grids/$inmesh.grd -O -K >> $outfile

    # Add axes
    psbasemap $area $proj -Ba5f1/a5f1WeSn -O -K >> $outfile

    # Model area
    psxy $area $proj -L -A -W5,black,- -O -K << DOMAIN >> $outfile
    -15 45
    -15 65
    15 65
    15 45
DOMAIN

    pstext $area $proj -N -O -K -Wwhite << TEXT >> $outfile 
3 47.5 10 0 0 1 $textlabel
TEXT
}

#for ((i=0; i<${#infiles[@]}; i++)); do
#    mkTri ${baseDir}/${infiles[i]}
#done

psxy $area $proj -K -T -P > $outfile
for ((i=0; i<${#infiles[@]}; i++)); do
    plotMap ${xPosA[i]} ${yPosA[i]} ${infiles[i]%.*} "${figlabel[i]}"
done
psscale -D-0.5/16.75/4/0.3 -Ba100f20:"Depth (m) MSL": -O -K -C./cpts/${infiles[0]%.*}.cpt >> $outfile
psxy $area $proj -O -T >> $outfile

formats $outfile
mv $outfile ./images/ps/
mv ${outfile%.*}.png ./images/png/

