#!/bin/bash

# script to plot the gebco bathy, with illumination from the west

. ~/.bash_profile > /dev/null

gmtdefaults -D > .gmtdefaults4
gmtset LABEL_FONT_SIZE=14
gmtset D_FORMAT=%g
gmtset PLOT_DEGREE_FORMAT F
gmtset BASEMAP_TYPE=plain

area=-R-20/15/45/65
proj=-Jm0.5

infile=./GEBCO_08.nc
outfile=./images/gebco_bathy.ps

doprep(){
   # make a continental shelf colour palette file
   makecpt -T-5000/0/0.1 -Z -Crainbow > shelf.cpt

   # cut out the region of interest
   grdcut $area -G./grids/${infile%.*}_cut.grd $infile -fg

   # clip out the land areas
   grdlandmask $area -G./grids/${infile%.*}_landmask.grd -I0.5m -Df -N1/NaN -F

   # make a gradient grid
   grdgradient ./grids/${infile%.*}_cut.grd -G./grids/${infile%.*}_grad_all.grd -Nt0.7 -E270/50

   # clip the gradient and bathy grids
   grdmath ./grids/${infile%.*}_cut.grd ./grids/${infile%.*}_landmask.grd MUL = ./grids/${infile%.*}_bathy.grd
   grdmath ./grids/${infile%.*}_grad_all.grd ./grids/${infile%.*}_landmask.grd MUL = ./grids/${infile%.*}_grad.grd
}

doplot(){
   # plot the image
   grdimage $area $proj ./grids/${infile%.*}_bathy.grd -Ba5f2.5g5WeSn -Cshelf.cpt -Xc -Yc -K -I./grids/${infile%.*}_grad.grd > $outfile

   # add a coastline for the area
   pscoast $area $proj -Ba5f2.5g5WeSn -Df -A100 -G0/0/0 -O -K -N1/255/255/255 -W1/255/255/255 >> $outfile

   # add the scale in
   psscale -D18.5/8.5/6/0.5 -B1000:"Depth(m)": -C./shelf.cpt -O >> $outfile
   # make a geotiff from the grid files
   #echo "making a geotiff... "
   #mbgrdtiff -I${infile%.*}_bathy.grd -K${infile%.*}_grad.grd -Cshelf.cpt -O${infile%.*}_bathy.tif
   #echo "done."

   # convert the images to jpeg and pdf from postscript
   formats $outfile
}

#doprep
doplot

exit 0
