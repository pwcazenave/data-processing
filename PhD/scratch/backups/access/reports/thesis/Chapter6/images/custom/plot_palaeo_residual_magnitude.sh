#!/bin/bash

# Plot the model shear stress results.

baseDir=./raw_data/
infile=palaeo_residual_0-8k.csv

area=-R-12/10/47/61
proj=-Jm0.24c

yrCols=(3 7 11 15 19)
yrs=(0 2 4 6 8)
xPosA=(1 0 7 -7 7)
yPosA=(15 -7 0 -7 0)

figlabel=("A 00.0ka" "B 02.0ka" "C 04.0ka" "D 06.0ka" "E 08.0ka")

base=palaeo_residual_transport_magnitude_bed_panels

outfile=./images/$base.ps

set -eu

gmtdefaults -D > .gmtdefaults4

gmtset BASEMAP_TYPE=plain PLOT_DEGREE_FORMAT=F ANNOT_FONT_SIZE=11 LABEL_FONT_SIZE=11 COLOR_NAN=white

mkTri(){
    rawinmesh=$1
    inmesh=$(basename $rawinmesh .csv)
    currCol=$2
    currYr=$3
    inbathy=/media/z/modelling/data/bathymetry/meshes/round_8_palaeo/ice-5g/depth/mesh/bte0y-$(printf "0%2.1f" $currYr)k_v5_peltier.mesh

    # Triangulate the points from the mesh
    # Multiply by a tide ~12.5 hours
    awk -F, '{print $1,$2,$'$currCol'*12.5*60*60}' $rawinmesh | \
        triangulate $area $proj -I10m -G./grids/${inmesh}_${currYr}_triangle.grd -H1 -m > ./raw_data/${inmesh}_${currYr}.xy;
    awk '{if (NF==5 && $4<0) print $2,$3,$4}' $inbathy | \
        grdmask $area -I10m -S0.3 -NNaN/1/1 -G./grids/${inmesh}_${currYr}_mask.grd
    grdmath ./grids/${inmesh}_${currYr}_mask.grd ./grids/${inmesh}_${currYr}_triangle.grd MUL = ./grids/${inmesh}_${currYr}.grd
}


plotMap(){
    xOff=$1
    yOff=$2
    inmesh=$(basename $3 .csv)
    currCol=$4
    textlabel="$5"
    currYr=$6
    inbathy=/media/z/modelling/data/bathymetry/meshes/round_8_palaeo/ice-5g/depth/mesh/bte0y-$(printf "0%2.1f" $currYr)k_v5_peltier.mesh

#    makecpt $(grdinfo ./grids/$inmesh.grd -T100) -Crainbow -Z > ./cpts/$inmesh.cpt
#    grd2cpt ./grids/$inmesh.grd -L-2000/0 -Crainbow -Z > ./cpts/$inmesh.cpt
    makecpt -T1e-8/10/3 -Qo -Cwysiwyg -Z > ./cpts/${inmesh}_${currYr}.cpt

    grdimage $area $proj -Ba5f1/a5f1WeSn ./grids/${inmesh}_${currYr}.grd -C./cpts/${inmesh}_${currYr}.cpt -O -K -X${xOff}c -Y${yOff}c -P >> $outfile

    # Add the mesh
#    psxy $area $proj -m -A ./raw_data/$inmesh.xy -O -K >> $outfile
    awk '{if (NF==5 && $4<0) print $2,$3,$4}' $inbathy | \
        psmask $area $proj -I10m -S10m -N -Ggrey -O -K >> $outfile
    psmask -C -O -K >> $outfile
    pscoast $area $proj -Dl -Gdarkgrey -W2,black -A50 -O -K >> $outfile

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

#for ((i=0; i<${#yrCols[@]}; i++)); do
#    mkTri $baseDir/$infile ${yrCols[i]} ${yrs[i]}
#done

psxy $area $proj -K -T -P > $outfile
for ((i=0; i<${#yrCols[@]}; i++)); do
    plotMap ${xPosA[i]} ${yPosA[i]} $infile ${yrCols[i]} "${figlabel[i]}" ${yrs[i]}
    #plotMap 1 $((1+$i)) $infile ${yrCols[i]} "${figlabel[i]}" ${yrs[i]}
done
psscale -D-0.5/16.75/4/0.3 -Qo -Ba1f0.5:"Residual transport (m@+3@+ tide@+-1@+ m@+-1@+)": -O -K -C./cpts/${inmesh}_${currYr}.cpt --D_FORMAT=%lg --LABEL_OFFSET=1.2c >> $outfile
psxy $area $proj -O -T >> $outfile

formats $outfile
mv $outfile ./images/ps/
mv ${outfile%.*}.png ./images/png/
