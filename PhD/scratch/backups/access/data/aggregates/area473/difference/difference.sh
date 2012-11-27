#!/bin/csh -f

# script to smooth the bathy data for area473 from 2005 and 2006 in order to
# determine if there's any difference between each area

##----------------------------------------------------------------------------##

# get the basics in
set area=-R314494/322135/5.59553e+06/5.59951e+06
set proj=-Jx0.003

# i/o
set infile_03=../2003/raw_data/0549_473East.xyz
set infile_05=../2005/swath/raw_data/area473_2005_3.pts
set infile_06=../2006/swath/raw_data/bathy_mean.xyz.bmd
#set outfile=./images/area473_difference.ps
set outfile_2003=./images/area473_2003.ps
set outfile_2005=./images/area473_2005.ps
set outfile_2006=./images/area473_2006.ps
set diff_06_03=./images/diff_06_03.ps
set diff_05_06=./images/diff_05_06.ps
set diff_03_05=./images/diff_03_05.ps

# page dimensions etc.
set a4=-R0/32/0/22
set page=-JX32c/22c

# labelling etc.
gmtset ANNOT_FONT_SIZE 12
gmtset LABEL_FONT_SIZE 12
gmtset HEADER_FONT_SIZE 14
gmtset ANNOT_FONT_SIZE_SECONDARY 12
gmtset HEADER_OFFSET 0.2c
gmtset D_FORMAT %7.9lg

##----------------------------------------------------------------------------##

# preprocess the data so you've got them on the same gridding etc.
# going to have to grid the data coarsely due to the poor resolution of the
# interferrometric data - will be at 2.5 metres.

# no need to blockmean the 2006 stuff, it's already been done at 2.5 metres
# 2003
#tr "," " " < $infile_03 | blockmean -I2.5 $area > ./raw_data/area473_2003.xyz.bmd
# 2005 - need to reverse depth values
#awk '{print $1, $2, $3*-1}' $infile_05 | blockmean -I2.5 $area > ./raw_data/area473_2005_3.pts.bmd
# 2006
#no need (see above)

# let's grid it on... oh dear.
# 2003
#surface -Garea473_2003_interp.grd -I2.5 $area -T0 ./raw_data/area473_2003.xyz.bmd
# 2005
#surface -Garea473_2005_interp.grd -I2.5 $area -T0 ./raw_data/area473_2005_3.pts.bmd
# 2006
#surface -Garea473_2006_interp.grd -I2.5 $area -T0 $infile_06

# the mask is back
# 2003
#grdmask ./raw_data/area473_2003.xyz.bmd -Garea473_2003_mask.grd -I2.5 $area -N/NaN/1/1 -S5
# 2005
#grdmask ./raw_data/area473_2005_3.pts.bmd -Garea473_2005_mask.grd -I2.5 $area -N/NaN/1/1 -S5
# 2006
#grdmask $infile_06 -Garea473_2006_mask.grd -I2.5 $area -N/NaN/1/1 -S5

# addthe 2006 mask to both since it's the smaller area
#grdmath area473_2003_interp.grd area473_2003_mask.grd MUL = area473_2003.grd
#grdmath area473_2005_interp.grd area473_2006_mask.grd MUL = area473_2005.grd
#grdmath area473_2006_interp.grd area473_2006_mask.grd MUL = area473_2006.grd

# illuminate the surface
#grdgradient area473_2003_interp.grd -A250 -Nt0.7 -Garea473_2003_grad.grd
#grdgradient area473_2005_interp.grd -A250 -Nt0.7 -Garea473_2005_grad.grd
#grdgradient area473_2006_interp.grd -A250 -Nt0.7 -Garea473_2006_grad.grd

##----------------------------------------------------------------------------##

# use grdfft to remove the high frequency noise (i.e. get rid of artefacts and
# just have the regional-scale bathy left
grdfft area473_2003_interp.grd -Garea473_2003_interp_fft.grd -L -F-/-/800/70
grdfft area473_2005_interp.grd -Garea473_2005_interp_fft.grd -L -F-/-/800/70
grdfft area473_2006_interp.grd -Garea473_2006_interp_fft.grd -L -F-/-/800/70

# recreate the illumination based on the smoothed data
grdgradient area473_2003_interp_fft.grd -A250 -Nt0.7 -Garea473_2003_grad.grd
grdgradient area473_2005_interp_fft.grd -A250 -Nt0.7 -Garea473_2005_grad.grd
grdgradient area473_2006_interp_fft.grd -A250 -Nt0.7 -Garea473_2006_grad.grd

# remask the areas
grdmath area473_2003_interp_fft.grd area473_2006_mask.grd MUL = \
   area473_2003_fft.grd
grdmath area473_2005_interp_fft.grd area473_2006_mask.grd MUL = \
   area473_2005_fft.grd
grdmath area473_2006_interp_fft.grd area473_2006_mask.grd MUL = \
   area473_2006_fft.grd

##----------------------------------------------------------------------------##

# do the difference analysis of the datasets
# just subtract one from the other initially
grdmath area473_2006_fft.grd area473_2003_fft.grd SUB = area473_diff_06_03.grd
grdmath area473_2005_fft.grd area473_2006_fft.grd SUB = area473_diff_05_06.grd
grdmath area473_2003_fft.grd area473_2005_fft.grd SUB = area473_diff_03_05.grd

# make a new illumination grid
grdgradient area473_diff_06_03.grd -A250 -Nt0.7 -Garea473_diff_06_03_grad.grd
grdgradient area473_diff_05_06.grd -A250 -Nt0.7 -Garea473_diff_05_06_grad.grd
grdgradient area473_diff_03_05.grd -A250 -Nt0.7 -Garea473_diff_03_05_grad.grd

##----------------------------------------------------------------------------##

# plot the images

# make a colour palette table
# 2003
makecpt -Cwysiwyg -T38/48/1 -I -Z > .bathy_03.cpt
# 2005
makecpt -Cwysiwyg -T38/48/1 -I -Z > .bathy_05.cpt
# 2006
makecpt -Cwysiwyg -T38/48/1 -I -Z > .bathy_06.cpt
# difference
grd2cpt -Cwysiwyg $area -Z area473_diff_06_03.grd > .diff_06_03.cpt
grd2cpt -Cwysiwyg $area -Z area473_diff_05_06.grd > .diff_05_06.cpt
grd2cpt -Cwysiwyg $area -Z area473_diff_03_05.grd > .diff_03_05.cpt

# plot the gridded data
# 2003
grdimage $area $proj \
   -Ba1000f500g1000:"Eastings":/a1000f500g1000:"Northings"::."Filtered Area 473 Swath Bathymetry for 2003":WeSn \
   -Iarea473_2003_grad.grd -C.bathy_03.cpt area473_2003_fft.grd \
   -K -Xc -Yc > $outfile_2003
# 2005
grdimage $area $proj \
   -Ba1000f500g1000:"Eastings":/a1000f500g1000:"Northings"::."Filtered Area 473 Swath Bathymetry for 2005":WeSn \
   -Iarea473_2005_grad.grd -C.bathy_05.cpt area473_2005_fft.grd \
   -K -Xc -Yc > $outfile_2005
# 2006
grdimage $area $proj \
   -Ba1000f500g1000:"Eastings":/a1000f500g1000:"Northings"::."Filtered Area 473 Swath Bathymetry for 2006":WeSn \
   -Iarea473_2006_grad.grd -C.bathy_06.cpt area473_2006_fft.grd \
   -K -Xc -Yc > $outfile_2006
# 2006-2003 difference
grdimage $area $proj \
   -Ba1000f500g1000:"Eastings":/a1000f500g1000:"Northings"::."Filtered Area 473 Swath Bathymetry Difference":WeSn \
   -C.diff_06_03.cpt area473_diff_06_03.grd \
   -K -Xc -Yc > $diff_06_03
# 2005-2006 difference
grdimage $area $proj \
   -Ba1000f500g1000:"Eastings":/a1000f500g1000:"Northings"::."Filtered Area 473 Swath Bathymetry Difference":WeSn \
   -C.diff_05_06.cpt area473_diff_05_06.grd \
   -K -Xc -Yc > $diff_05_06
# 2003-2005 difference
grdimage $area $proj \
   -Ba1000f500g1000:"Eastings":/a1000f500g1000:"Northings"::."Filtered Area 473 Swath Bathymetry Difference":WeSn \
   -C.diff_03_05.cpt area473_diff_03_05.grd \
   -K -Xc -Yc > $diff_03_05

# add in the colour scales and labels
psbasemap $a4 $page -B0 -O -K -X-4 -Y-5 >> $outfile_2003
psbasemap $a4 $page -B0 -O -K -X-4 -Y-5 >> $outfile_2005
psbasemap $a4 $page -B0 -O -K -X-4 -Y-5 >> $outfile_2006
psbasemap $a4 $page -B0 -O -K -X-4 -Y-5 >> $diff_06_03
psbasemap $a4 $page -B0 -O -K -X-4 -Y-5 >> $diff_05_06
psbasemap $a4 $page -B0 -O -K -X-4 -Y-5 >> $diff_03_05

# 2003
psscale -B2 -C.bathy_03.cpt -D28/10/-3/0.4 -O -K >> $outfile_2003
pstext $page $a4 -O -K << 2003 >> $outfile_2003
28 12 12 0 0 1 Depth (m)
2003
# 2005
psscale -B2 -C.bathy_05.cpt -D28/10/-3/0.4 -O -K >> $outfile_2005
pstext $page $a4 -O << 2005 >> $outfile_2005
28 12 12 0 0 1 Depth (m)
2005
# 2006
psscale -B2 -C.bathy_06.cpt -D28/10/-3/0.4 -O -K >> $outfile_2006
pstext $page $a4 -O << 2006 >> $outfile_2006
28 12 12 0 0 1 Depth (m)
2006
# diff_06_03
psscale -B1 -C.diff_06_03.cpt -D28/10/3/0.4 -O -K >> $diff_06_03
pstext $page $a4 -O << DIFF_06_03 >> $diff_06_03
27.4 12 12 0 0 1 Difference (m)
DIFF_06_03
# diff_05_06
psscale -B1 -C.diff_05_06.cpt -D28/10/3/0.4 -O -K >> $diff_05_06
pstext $page $a4 -O << DIFF_05_06 >> $diff_05_06
27.4 12 12 0 0 1 Difference (m)
DIFF_05_06
# diff_03_05
psscale -B1 -C.diff_03_05.cpt -D28/10/3/0.4 -O -K >> $diff_03_05
pstext $page $a4 -O << DIFF_03_05 >> $diff_03_05
27.4 12 12 0 0 1 Difference (m)
DIFF_03_05

##----------------------------------------------------------------------------##

# view the image
#gs -sPAPERSIZE=a4 $outfile
#ps2pdf -dOptimize=true -dPDFSETTINGS=/screen -sPAPERSIZE=a4 $outfile
ps2pdf -dOptimize=true -sPAPERSIZE=a4 $outfile_2003
ps2pdf -dOptimize=true -sPAPERSIZE=a4 $outfile_2005
ps2pdf -dOptimize=true -sPAPERSIZE=a4 $outfile_2006
ps2pdf -dOptimize=true -sPAPERSIZE=a4 $diff_06_03
ps2pdf -dOptimize=true -sPAPERSIZE=a4 $diff_05_06
ps2pdf -dOptimize=true -sPAPERSIZE=a4 $diff_03_05
