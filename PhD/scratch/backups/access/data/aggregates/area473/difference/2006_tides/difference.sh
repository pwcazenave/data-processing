#!/bin/csh -f

# script to smooth the bathy data for area473 from 2005 and 2006 in order to
# determine if there's any difference between each area

##----------------------------------------------------------------------------##

# get the basics in
set area=-R314494/322135/5.59553e+06/5.59951e+06
set proj=-Jx0.003

# i/o
set infile_06_p1hr=../../2006/swath/raw_data/area473_2006_+1hr.txt.bmd
set infile_06_m1hr=../../2006/swath/raw_data/area473_2006_-1hr.txt.bmd
set outfile_2006_p1hr=./images/area473_2006_p1hr.ps
set outfile_2006_m1hr=./images/area473_2006_m1hr.ps
set diff_05_06_p1hr=./images/diff_05_06_p1hr.ps
set diff_05_06_m1hr=./images/diff_05_06_m1hr.ps

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

# turn the 2006 depths into negative values to match everything else...
awk '{print $1, $2, $3*-1}' $infile_06_p1hr > 2006_p1hr.xyz
awk '{print $1, $2, $3*-1}' $infile_06_m1hr > 2006_m1hr.xyz

# let's grid it on... oh dear.
# 2005
surface -Garea473_2005_interp.grd -I2.5 $area -T0 ../../2005/swath/raw_data/area473_2005_3.pts
# 2006
surface -Garea473_2006_p1hr_interp.grd -I2.5 $area -T0 2006_p1hr.xyz
surface -Garea473_2006_m1hr_interp.grd -I2.5 $area -T0 2006_m1hr.xyz

# add the 2006 mask to both since it's the smaller area
grdmath area473_2005_interp.grd ../area473_2006_mask.grd MUL = \
   area473_2005.grd
grdmath area473_2006_p1hr_interp.grd ../area473_2006_mask.grd MUL = \
   area473_2006_p1hr.grd
grdmath area473_2006_m1hr_interp.grd ../area473_2006_mask.grd MUL = \
   area473_2006_m1hr.grd

# illuminate the surface
grdgradient area473_2005_interp.grd -A250 -Nt0.7 -Garea473_2005_grad.grd
grdgradient area473_2006_p1hr_interp.grd -A250 -Nt0.7 -Garea473_2006_p1hr_grad.grd
grdgradient area473_2006_m1hr_interp.grd -A250 -Nt0.7 -Garea473_2006_m1hr_grad.grd

##----------------------------------------------------------------------------##

# use grdfft to remove the high frequency noise (i.e. get rid of artefacts and
# just have the regional-scale bathy left
grdfft area473_2005_interp.grd \
   -Garea473_2005_interp_fft.grd -L -F-/-/800/70
grdfft area473_2006_p1hr_interp.grd \
   -Garea473_2006_interp_p1hr_fft.grd -L -F-/-/800/70
grdfft area473_2006_m1hr_interp.grd \
   -Garea473_2006_interp_m1hr_fft.grd -L -F-/-/800/70

# recreate the illumination based on the smoothed data
grdgradient area473_2005_interp_fft.grd -A250 -Nt0.7 \
   -Garea473_2005_fft_grad.grd
grdgradient area473_2006_interp_p1hr_fft.grd -A250 -Nt0.7 \
   -Garea473_2006_p1hr_fft_grad.grd
grdgradient area473_2006_interp_m1hr_fft.grd -A250 -Nt0.7 \
   -Garea473_2006_p1hr_fft_grad.grd

# remask the areas
grdmath area473_2005_interp_fft.grd ../area473_2006_mask.grd MUL = \
   area473_2005_fft.grd
grdmath area473_2006_interp_p1hr_fft.grd ../area473_2006_mask.grd MUL = \
   area473_2006_p1hr_fft.grd
grdmath area473_2006_interp_m1hr_fft.grd ../area473_2006_mask.grd MUL = \
   area473_2006_m1hr_fft.grd

##----------------------------------------------------------------------------##

# do the difference analysis of the datasets
# just subtract one from the other initially
grdmath area473_2005_fft.grd area473_2006_p1hr_fft.grd SUB = \
   area473_diff_05_06_p1hr.grd
grdmath area473_2005_fft.grd area473_2006_m1hr_fft.grd SUB = \
   area473_diff_05_06_m1hr.grd

# make a new illumination grid
grdgradient area473_diff_05_06_p1hr.grd -A250 -Nt0.7 \
   -Garea473_diff_05_06_p1hr_grad.grd
grdgradient area473_diff_05_06_m1hr.grd -A250 -Nt0.7 \
   -Garea473_diff_05_06_m1hr_grad.grd

##----------------------------------------------------------------------------##

# plot the images

# make a colour palette tables
makecpt -Cwysiwyg -T38/48/1 -I -Z > .bathy_06.cpt
grd2cpt -Cwysiwyg $area -Z area473_diff_05_06_p1hr.grd > \
   .diff_05_06_p1hr.cpt
grd2cpt -Cwysiwyg $area -Z area473_diff_05_06_m1hr.grd > \
   .diff_05_06_m1hr.cpt

# plot the gridded data
# 2006 plus 1 hour
grdimage $area $proj \
   -Ba1000f500g1000:"Eastings":/a1000f500g1000:"Northings"::."Filtered Area 473 Swath Bathymetry for 2006 (Plus 1 Hour)":WeSn \
   -Iarea473_2006_p1hr_grad.grd -C.bathy_06.cpt area473_2006_p1hr_fft.grd \
   -K -Xc -Yc > $outfile_2006_p1hr
# 2006 minus 1 hour
grdimage $area $proj \
   -Ba1000f500g1000:"Eastings":/a1000f500g1000:"Northings"::."Filtered Area 473 Swath Bathymetry for 2006 (Minus 1 Hour)":WeSn \
   -Iarea473_2006_m1hr_grad.grd -C.bathy_06.cpt area473_2006_m1hr_fft.grd \
   -K -Xc -Yc > $outfile_2006_m1hr
# 2005-2006 difference p1hr
grdimage $area $proj \
   -Ba1000f500g1000:"Eastings":/a1000f500g1000:"Northings"::."Filtered Area 473 Swath Bathymetry Difference (Plus 1 Hour)":WeSn \
   -C.diff_05_06_p1hr.cpt area473_diff_05_06_p1hr.grd \
   -K -Xc -Yc > $diff_05_06_p1hr
# 2005-2006 difference m1hr
grdimage $area $proj \
   -Ba1000f500g1000:"Eastings":/a1000f500g1000:"Northings"::."Filtered Area 473 Swath Bathymetry Difference (Minus 1 Hour)":WeSn \
   -C.diff_05_06_m1hr.cpt area473_diff_05_06_m1hr.grd \
   -K -Xc -Yc > $diff_05_06_m1hr

# add in the colour scales and labels
psbasemap $a4 $page -B0 -O -K -X-4 -Y-5 >> $outfile_2006_p1hr
psbasemap $a4 $page -B0 -O -K -X-4 -Y-5 >> $outfile_2006_m1hr
psbasemap $a4 $page -B0 -O -K -X-4 -Y-5 >> $diff_05_06_p1hr
psbasemap $a4 $page -B0 -O -K -X-4 -Y-5 >> $diff_05_06_m1hr

# 2006 p1hr
psscale -B2 -C.bathy_06.cpt -D28/10/-3/0.4 -O -K >> $outfile_2006_p1hr
pstext $page $a4 -O << 2006 >> $outfile_2006_p1hr
28 12 12 0 0 1 Depth (m)
2006
# 2006 m1hr
psscale -B2 -C.bathy_06.cpt -D28/10/-3/0.4 -O -K >> $outfile_2006_m1hr
pstext $page $a4 -O << 2006 >> $outfile_2006_m1hr
28 12 12 0 0 1 Depth (m)
2006
# diff_05_06 p1hr
psscale -B0.5 -C.diff_05_06_p1hr.cpt -D28/10/3/0.4 -O -K >> $diff_05_06_p1hr
pstext $page $a4 -O << DIFF_05_06 >> $diff_05_06_p1hr
27.4 12 12 0 0 1 Difference (m)
DIFF_05_06
# diff_05_06 m1hr
psscale -B0.5 -C.diff_05_06_m1hr.cpt -D28/10/3/0.4 -O -K >> $diff_05_06_m1hr
pstext $page $a4 -O << DIFF_05_06 >> $diff_05_06_m1hr
27.4 12 12 0 0 1 Difference (m)
DIFF_05_06

##----------------------------------------------------------------------------##

# view the image
#gs -sPAPERSIZE=a4 $outfile
#ps2pdf -dOptimize=true -dPDFSETTINGS=/screen -sPAPERSIZE=a4 $outfile
ps2pdf -dOptimize=true -sPAPERSIZE=a4 $outfile_2006_p1hr
ps2pdf -dOptimize=true -sPAPERSIZE=a4 $outfile_2006_m1hr
ps2pdf -dOptimize=true -sPAPERSIZE=a4 $diff_05_06_p1hr
ps2pdf -dOptimize=true -sPAPERSIZE=a4 $diff_05_06_m1hr
