#!/bin/bash

# Plot the HSB sidescan

area=-R0.5/0.7/50.688/50.762
proj=-Jm120
#area=-R0.2/1/50.575/50.875
#proj=-Jm32
outfile=./images/hsb_sss_interp.ps
cpt=./cpts/hsb.cpt
bkscpt=./cpts/hsb_sss_interp.cpt
szgrd=./grids/seazone.grd
cmapgrd=./grids/cmap_bathy.grd
rma2005=$HOME/mres/project/sidescan/hsb_interp_latlong.grd

gmtdefaults -D > .gmtdefaults4

gmtset BASEMAP_TYPE=plain LABEL_FONT_SIZE=14

makecpt -T-65/0/0.5 -Z -Ccopper > $cpt
makecpt -T0/65/0.5 -Z -I -Ccopper > ${cpt%.*}_pos.cpt
makecpt -T0.1/20/3 -Qo -Crainbow > $bkscpt

makegrid(){
#    surface -V -R-3.38736/-3.21498/51.26171/51.30936 -I2e \
#        ${rma2005%.*}.xyz -G${rma2005%.*}_surface.grd -T0.25
#    grdmask -R -NNaN/1/1 -I2e -S2 ${rma2005%.*}.xyz \
#        -G${rma2005%.*}_mask.grd
#    grdmath ${rma2005%.*}_surface.grd ${rma2005%.*}_mask.grd MUL = $rma2005
#    \rm -f ${rma2005%.*}_surface.grd ${rma2005%.*}_mask.grd
    xyz2grd -R0.521167286522237/0.670942860839771/50.6910222261275/50.7609127234599 \
        ${rma2005%.*}.xyz -G${rma2005} -I0.0002 -F
}

basics(){
    psbasemap $area $proj -Ba0.05f0.025/a0.025f0.0125WeSn -Xc -Yc \
        --BASEMAP_TYPE=plain --D_FORMAT=%lg --PLOT_DEGREE_FORMAT=DF -K \
        > $outfile
}

bgplot(){
    # SeaZone data
    if [ ! -f $szgrd ]; then
        xyz2grd $(minmax -I0.001 $szxyz) -I65e -G$szgrd $szxyz
    fi
    if [ ! -f ${szgrd%.grd}_grad.grd ]; then
        grdgradient -A300 -Nt0.7 $szgrd -G${szgrd%.grd}_grad.grd
    fi
    grdimage $area $proj -C$cpt -O -K $szgrd -I${szgrd%.*}_grad.grd -Q \
        >> $outfile
#    grdimage $area $proj -C$cpt -O -K $cmapgrd -I${cmapgrd%.*}_grad.grd -Q \
#        >> $outfile
}

plotbackscatter(){
    # 2005 sss data
    grdimage $area $proj -C$bkscpt -O -K "$rma2005" -Q \
        >> $outfile
    # Add colour palette for the backscatter
    psscale -C$bkscpt -D12/16.5/9/0.5h -Q -Ba1f3:"Grain Size (mm)": -O -K >> $outfile
}

decorations(){
    psscale -C$cpt -D12/-1.2/9/0.5h -Ba10f2:"Depth (m)": -I -O -K >> $outfile
    # Location map
    psbasemap -R-1/2/49.75/51.25 -Jm1.5 -O -K -Y0.25 -X19.3 -B0 >> $outfile
    pscoast -Df -R -B0 -Jm1.5 --PLOT_DEGREE_FORMAT=-DF -Swhite \
        -W2 -Na -Ggray -O -K >> $outfile
    psxy -R -J -L -O -K -W2 << HSB >> $outfile
    area=-R0.5/0.7/50.688/50.762
    0.5 50.688
    0.5 50.762
    0.7 50.762
    0.7 50.688
HSB
    pstext -R -J -O -K -N << LABEL >> $outfile
    -0.9 50.25 10 0 0 1 Hastings Shingle Bank
    -0.8 51 10 0 0 1 ENGLAND
    1.9 50 10 90 0 1 FRANCE
LABEL
    psxy -R -J -SVt0.1/0.3/0.15 -O -K -Gblack << ARROW >> $outfile
    0.5 50.4 10 0.55
ARROW
}

#makegrid
basics
bgplot
plotbackscatter
decorations
psxy $area $proj -T -O >> $outfile

formats $outfile
