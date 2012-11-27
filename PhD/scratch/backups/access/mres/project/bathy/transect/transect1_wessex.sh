#! /bin/csh

# script to plot transects of bathymetry for the two datasets (wesseax archaeology and hanson aggregate marine)

set area=-R330528/331195/5623910/5624280
set area2=-R330731/331056/-25/-19
set area4=-R0/22/0/30

set proj=-JX5.3/2.9
set proj2=-JX5.3/4
set proj3=-JX22c/30c

set outfile=wessex_transect.ps

gmtset LABEL_FONT_SIZE = 12
gmtset HEADER_FONT_SIZE	= 16p

# increase the precision of the output file since the northings are 6 digits long, this avoids output as follows: 5.62394e+06 
gmtset D_FORMAT %.10lf


# generate and display a transect across the wreck

# use project to make a line from two coordinates for grdtrack to sample along
project ../hanson_wessex_comparison/raw_data/wessex_arch.txt -C330700/5623900 -E331100/5624300 -N -L0/1 -Fxy -V > wessex_transect_coords.xy

# use grdtrack to plot the depths along the line generated using project from a grid file
grdtrack wessex_transect_coords.xy -G../hanson_wessex_comparison/wessex_arch_mask.grd $area -V | awk '{print $1, $3}' > wessex_transect_depths.xy

# return the decimal points to their original length
gmtset D_FORMAT %.0lf


# plot the data

# make the top basemap - transect line
psbasemap $proj $area -X1.5 -Y6.6 -B100:"Eastings":/100:"Northings"::."Wessex Archaeology Group Bathymetry":WeSn -P -K > $outfile

# plot the image of the transect line
grdimage $proj $area -I../hanson_wessex_comparison/wessex_arch_grad.grd -C../hanson_wessex_comparison/wessex_arch.cpt ../hanson_wessex_comparison/wessex_arch_mask.grd -O -K >> $outfile

# add the transect line
psxy $proj $area wessex_transect_coords.xy -W255/0/0 -O -K >> $outfile

# add a scale bar
psscale -D5.8/1.4/2/0.2 -B1 -C../hanson_wessex_comparison/wessex_arch.cpt -O -K >> $outfile

# map the bottom basemap - the graph
psbasemap $proj2 $area2 -Y-5.3 -B100:"Eastings":/1:"Depth (m)"::."Depth along the profile":WeSn -O -K >> $outfile

# plot the graph of the transect
psxy $proj2 $area2 -O -K -Sp -W255/0/0 wessex_transect_depths.xy >> $outfile

# add labels to the images, and the label to the scale bar using pstext
pstext $proj3 $area4 -X-1.5 -Y-1.5 -O << TEXT >> $outfile
#0 26 10 0.0 1 1 A
#0 13 10 0.0 1 1 B
#18.1 10.5 12 0.0 1 1 Depth (m)
18.1 23.8 12 0.0 1 1 Depth (m)
TEXT

# view the image
gs -sPAPERSIZE=a4 $outfile
