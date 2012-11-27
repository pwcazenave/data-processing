#! /bin/csh

# script to convert xyz data into grids and then into postscipt images.


# set some common variables
set area1=-R3305/3311/56239/56241
set area2=-R330555/331185/5624020/5624150
set proj1=-JX10c
set outfile=0091_0092.ps


# first file: 0091_-_Extra_Wrecks.txt

# use awk to divide the eastings and northings by 100 so that you don't end up with coordinates along the lines of 5.624e+06...
awk '{print ($1/100), ($2/100), $3}' raw_data/0091_-_Extra_Wrecks.txt > ../bathy/0091.txt

# preprocess the data with blockmean to assign a value to every point and grid data
blockmean 0091.txt -I0.000001 $area1 | surface -G0091.grd -I0.000001 $area1 -T0.25 -V

# plotting the grid file 0091.grd
psbasemap $proj1 $area1 -B100/10 -Xc -Y6.2 -P -K > $outfile
makecpt -Cwysiwyg -T-25/-18/1 -Z > ocean.cpt
grdimage $proj1 $area1 -Cocean.cpt 0091.grd -O -K >> $outfile


# second file: 0092_-_Extra_Wrecks.txt

# preprocess the data with blockmean to assign a value to every point
#blockmean ../raw_data/0092_-_Extra_Wrecks.txt -I5m $area2 > bm0092.xyz

# grid at 1 minute interval
#surface bm0092.xyz -G0092.grd -I5m -R -T0.25 -V

# plotting the grid file 0092.grd
#psbasemap $proj1 $area2 -B100/10 -Y-5.8 -P -O -K >> $outfile
#makecpt -Cwysiwyg -T-25/-18/1 -Z > ocean.cpt
#grdimage $proj1 $area2 -Cocean.cpt 0092.grd -O -K >> $outfile

# add a scale
psscale -D2/5.2/5.5/0.2h -B2:"Depth (m)": -Cocean.cpt -O >> $outfile

# view the image (plot.ps)
gs -sPAPERSIZE=a4 $outfile


