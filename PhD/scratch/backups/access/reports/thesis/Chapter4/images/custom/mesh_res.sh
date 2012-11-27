#!/bin/bash

# Plot the model mesh

infile=./raw_data/mesh_res_stats.mesh
proj=-Jx0.00023c

base=$(basename ${infile%.*})

outfile=./images/$base.ps

set -eu

gmtdefaults -D > .gmtdefaults4

gmtset BASEMAP_TYPE=plain PLOT_DEGREE_FORMAT=F ANNOT_FONT_SIZE=16 LABEL_FONT_SIZE=18 COLOR_NAN=white

mkTri(){
    # Triangulate the points from the mesh
    awk '{if (NF==5) print $2,$3,$4}' $infile > ./raw_data/${base}_extracted.xy
    # Add the mesh extents too
    echo "699319.34229703 5619573.20187555 0" >> ./raw_data/${base}_extracted.xy
    echo "800718.823342209 5624452.16272519 0" >> ./raw_data/${base}_extracted.xy
    echo "805056.293436048 5548754.03460083 0" >> ./raw_data/${base}_extracted.xy
    echo "702217.387688178 5544054.47656009 0" >> ./raw_data/${base}_extracted.xy
    triangulate -H1 -m ./raw_data/${base}_extracted.xy > ./raw_data/$base.xy;
}


plotMap(){
    area=$(minmax -I1000 -m ./raw_data/$base.xy)
    # Add the mesh
    psxy $area $proj -m -A ./raw_data/$base.xy \
        -Ba10000f2000:"Eastings":/a10000f2000:"Northings":WeSn \
        -W3 -X3.6c -Y1.95c > $outfile
}

#mkTri
plotMap
formats $outfile

