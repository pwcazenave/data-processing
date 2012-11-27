#!/bin/bash

# Plot the Cuvler Sands backscatter

area=-R-3.421/-3.175/51.245/51.325
proj=-Jm100
outfile=./images/culver_sands_backscatter.ps
cpt=./cpts/culver.cpt
bkscpt=./cpts/backscatter2.cpt
szgrd=./grids/sz50x50_latlong.grd
szxyz=$HOME/data/seazone/SevernEstuary/raw_data/sz50x50_latlong.xyz
bodcgrd=$HOME/data/bodc/random_bathy/grids/1kmdep.grd
rma2010=$HOME'/data/aggregates/culver_sands/2010/Charts&Dwg/8550_culver_mosaic_2010_latlong.grd'
crest_points=$HOME/data/arcmap_shapefiles/culver/historic/crests_points.csv

gmtdefaults -D > .gmtdefaults4

gmtset BASEMAP_TYPE=plain LABEL_FONT_SIZE=14

makecpt -T-25/0/0.5 -Z -Ccopper > $cpt
makecpt -T0/25/0.5 -Z -I -Ccopper > ${cpt%.*}_pos.cpt
#makecpt -T75/106/1 -Cgray > $bkscpt

makegrid(){
    surface -V -R-3.38736/-3.21498/51.26171/51.30936 -I1e \
        ${rma2010%.*}.xyz -G${rma2010%.*}_surface.grd -T0.25
    grdmask -R -NNaN/1/1 -I1e -S2 ${rma2010%.*}.xyz \
        -G${rma2010%.*}_mask.grd
    grdmath ${rma2010%.*}_surface.grd ${rma2010%.*}_mask.grd MUL = $rma2010
    \rm -f ${rma2010%.*}_surface.grd ${rma2010%.*}_mask.grd
}

basics(){
    psbasemap $area $proj -Ba0.05f0.025/a0.025f0.0125WeSn -Xc -Yc \
        --BASEMAP_TYPE=plain --D_FORMAT=%lg --PLOT_DEGREE_FORMAT=-DF -K \
        > $outfile
}

bgplot(){
    # BODC data
    grdimage $area $proj -C$cpt -O -K $bodcgrd >> $outfile

    # SeaZone data
    if [ ! -f $szgrd ]; then
        xyz2grd $(minmax -I0.001 $szxyz) -I65e -G$szgrd $szxyz
    fi
    if [ ! -f ${szgrd%.grd}_grad.grd ]; then
        grdgradient -A300 -Nt0.7 $szgrd -G${szgrd%.grd}_grad.grd
    fi
    grdimage $area $proj -C$cpt -O -K $szgrd -I${szgrd%.*}_grad.grd -Q \
        >> $outfile
}

plotbackscatter(){
    # 2010 backscatter data
    grdimage $area $proj -C$bkscpt -O -K "$rma2010" -Q \
        >> $outfile
    # Add colour palette for the backscatter
#    psscale -C$bkscpt -D12/15.3/9/0.5h -Ba50f10:"Backscatter intensity": -O -K >> $outfile
}

decorations(){
    psscale -C$cpt -D12/-1.2/9/0.5h -Ba5f1:"Depth (m)": -I -O -K >> $outfile
    psbasemap -R-5.5/-2/50.75/52 -Jm1.5 -O -K -Y9.5 -X0.25 -B0 >> $outfile
    pscoast -Df -R-5.5/-2/50.75/52 -B0 -Jm1.5 --PLOT_DEGREE_FORMAT=-DF -Swhite \
        -W2 -Na -Ggray -O -K >> $outfile
    psxy -R -J -L -O -K -W2 << CULVER >> $outfile
    -3.395 51.253
    -3.395 51.31
    -3.216 51.31
    -3.216 51.253
CULVER
    pstext -R -J -O -K -N << LABEL >> $outfile
    -5.35 51.3 10 0 0 1 Culver Sands
    -3.7 51.8 10 0 0 1 WALES
    -3.4 50.9 10 0 0 1 ENGLAND
LABEL
    psxy -R -J -SVt0.1/0.3/0.15 -O -K -Gblack << ARROW >> $outfile
    -3.85 51.35 100 0.55
ARROW
}

#makegrid
basics
bgplot
plotbackscatter
decorations
psxy $area $proj -T -O >> $outfile

formats $outfile
