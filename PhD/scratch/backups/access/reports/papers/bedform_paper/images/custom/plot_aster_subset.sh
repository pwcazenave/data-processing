#!/bin/bash

# Script to plot the ASTER GDEM data. May have results at some point too...

gmtdefaults -D > .gmtdefaults4
gmtset ANNOT_FONT_SIZE=16 LABEL_FONT_SIZE=16 BASEMAP_TYPE=plain COLOR_BACKGROUND=purple COLOR_FOREGROUND=red

ingrd=./grids/aster_gdem_utm_30m.grd
#ingrd=./grids/aster_gdem_utm_250m.grd
interp_big=./raw_data/aster_big_extents.csv
interp_little=./raw_data/aster_little_extents.csv

area=$(grdinfo -I100 $ingrd)
west2=600000
east2=625000
south2=2054000
north2=2084000
west1=620000
east1=645000
south1=2110000
north1=2140000
area1=-R$west1/$east1/$south1/$north1
area2=-R$west2/$east2/$south2/$north2
proj1=-Jx30e-5
proj2=-Jx30e-5

outfile=./images/$(basename ${ingrd%.*})_subset.ps

set -eu

plot_subset1(){
    grdcut $area1 $ingrd -G${ingrd%.*}_subset1.grd
    grdgradient -Nt1.1 -A160 ${ingrd%.*}_subset1.grd \
        -G${ingrd%.*}_subset1_grad.grd
    makecpt $(grdinfo -T10 ${ingrd%.*}_subset1.grd) -Z -Crainbow \
        > ./cpts/$(basename ${ingrd%.*})_subset1.cpt
    psbasemap $area1 $proj1 -X4c -K \
        -Ba10000f2000:"Eastings":/a10000f2000:"Northings":WeSn \
        > $outfile
    grdimage $area1 $proj1 -C./cpts/$(basename ${ingrd%.*})_subset1.cpt \
        -I${ingrd%.*}_subset1_grad.grd \
        ${ingrd%.*}_subset1.grd -O -K >> $outfile
    gmtset ANNOT_FONT_SIZE=12 LABEL_FONT_SIZE=12
    psscale -D3.75/11.5/6/0.4h -Ba50f10:"Height (m)": \
        -C./cpts/$(basename ${ingrd%.*})_subset1.cpt -I -O -K >> $outfile
    gmtset ANNOT_FONT_SIZE=16 LABEL_FONT_SIZE=16
}

plot_subset2(){
    grdcut $area2 $ingrd -G${ingrd%.*}_subset2.grd
    grdgradient -Nt1.1 -A160 ${ingrd%.*}_subset2.grd \
        -G${ingrd%.*}_subset2_grad.grd
    makecpt $(grdinfo -T10 ${ingrd%.*}_subset2.grd) -Z -Crainbow \
        > ./cpts/$(basename ${ingrd%.*})_subset2.cpt
    psbasemap $area2 $proj2 -X9c -O -K \
        -Ba10000f2000:"Eastings":/a10000f2000:"Northings":wESn \
        >> $outfile
    grdimage $area2 $proj2 -C./cpts/$(basename ${ingrd%.*})_subset2.cpt \
        -I${ingrd%.*}_subset2_grad.grd \
        ${ingrd%.*}_subset2.grd -O -K >> $outfile
    gmtset ANNOT_FONT_SIZE=12 LABEL_FONT_SIZE=12
    psscale -D3.75/11.5/6/0.4h -Ba50f10:"Height (m)": \
        -C./cpts/$(basename ${ingrd%.*})_subset2.cpt -I -O >> $outfile
    gmtset ANNOT_FONT_SIZE=16 LABEL_FONT_SIZE=16
}

plot_subset1 $area1 $proj1
plot_subset2 $area2 $proj2
formats $outfile
mv $outfile ./images/ps
mv ${outfile%.*}.png ./images/png/
