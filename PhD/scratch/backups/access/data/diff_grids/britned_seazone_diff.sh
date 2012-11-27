#!/bin/bash

# script to plot the seazone data and the britned data to determine differences
# in the z values

# given the coarsest value (from CMAP)
# CMAP = 0.1 minute (575x930m)
# SeaZone = 0.002 degrees (134x220m) (~0.12minutes)
# BritNed = 0.12 minute = 200m
grid_size=0.003 # in degrees
gres=-I"$grid_size"

britned_in=../britned/raw_data/BritNed_bathy_modeledited.dat
seazone_in=../seazone/Bathy/gridded_bathy/bathy.xyz
britned_grid=./grids/britned_sn_sea_"$grid_size"deg.grd
seazone_grid=./grids/seazone_sn_sea_"$grid_size"deg.grd
outfile=./images/britned_seazone_sn_sea.ps
hist=./images/britned_seazone_histogram.ps

#area=-R-7/5/47.5/53
area=-R0/3/51/52.5
proj=-Jm6
h_proj=-JX17/11

gmtset D_FORMAT=%g
gmtset PLOT_DEGREE_FORMAT=F
gmtset LABEL_FONT_SIZE=18
gmtset ANNOT_FONT_SIZE=18

# convert britned to lat/long
#mapproject $area $britned_in -Ju31/1:1 -C -F -I \
#   > ../britned/raw_data/britned_bathy_wgs84.txt
# seems to be accurate to +/- 2m or so... close enough for this, I think.

# replace existing britned_in variable with lat/long version
britned_in=../britned/raw_data/britned_bathy_wgs84.txt

# make grids, not war
#xyz2grd $area $gres -G$britned_grid $britned_in
#awk '{if ($3<1) print $1,$2,$3}' $seazone_in | \
#   xyz2grd $area $gres -G$seazone_grid

# make a difference grid
#grdmath ./grids/britned_sn_sea_"$grid_size"deg.grd \
#   ./grids/seazone_sn_sea_"$grid_size"deg.grd SUB = \
#   ./grids/britned_seazone_"$grid_size"deg_diff.grd

# make an appropriate colour palette
#grd2cpt $area -Cwysiwyg -L-10/10 \
#   ./grids/britned_seazone_"$grid_size"deg_diff.grd \
#   > ./bs_diff.cpt
makecpt makecpt -T-6/6/0.1 -Z -Cwysiwyg > ./bs_diff.cpt

# plot the image
grdimage $area $proj ./grids/britned_seazone_"$grid_size"deg_diff.grd \
   -Ba0.5f0.25g0.5WeSn \
   -C./bs_diff.cpt \
   -K -Xc -Yc > $outfile

# add a coastline for the area
pscoast $area $proj -B0 -Df -G0/0/0 -O -K -N1/255/255/255 -W1/255/255/255 >> $outfile

# add the scale in
psscale -D20.7/6/6/0.5 -Ba2f1 -C./bs_diff.cpt -O -K >> $outfile
pstext $area $proj -N -O << TEXT >> $outfile
3.2 52.1 18 0 0 1 Difference (m)
TEXT

# do the histograms...
# reset font sizes for histograms since they're full page anyway
gmtset LABEL_FONT_SIZE=12
gmtset ANNOT_FONT_SIZE=12

# create and plot a histogram (frequency and cumulative)
grd2xyz -S ./grids/britned_seazone_"$grid_size"deg_diff.grd \
   > ./grids/britned_seazone_"$grid_size"deg_diff.txt

pshistogram ./grids/britned_seazone_"$grid_size"deg_diff.txt \
   $h_proj -R-8/8/0/18 -G100/100/100 -W0.25 -L1/0/0/0 -K -P \
   -T2 -Z1 -Xc -Y17c \
   -Ba2f1g2:Difference\ \(m\):/a2f0.5g2:,-%:WeSn \
   > $hist

mean=$(
   printf %.2f \
   $(cut -f3 ./grids/britned_seazone_"$grid_size"deg_diff.txt | mean.awk)
   )
stddev=$(
   printf %.2f \
   $(cut -f3 ./grids/britned_seazone_"$grid_size"deg_diff.txt | std_dev.awk)
   )
range=$(
   printf %.2f \
   $(cut -f3 ./grids/britned_seazone_"$grid_size"deg_diff.txt | minmax -C | \
   awk '{print sqrt($1**2)+sqrt($2**2)}')
   )
kurtosis=$(
   printf %.2f \
   $(cut -f3 ./grids/britned_seazone_"$grid_size"deg_diff.txt | \
   stat_moments.awk | \
   grep kurtosis | cut -f2 -d":")
   )

pstext -J -R -O -K -N -W255/255/255 << STDDEV >> $hist
-7.7 17.2 10 0 0 1 Standard deviation = ${stddev}m
-7.7 16.3 10 0 0 1 Mean = ${mean}m
-7.7 15.4 10 0 0 1 Range = ${range}m
-7.7 14.5 10 0 0 1 Kurtosis = ${kurtosis}m
STDDEV

# remove the modal value from the difference grid output (-1.7939m) before \
# getting absolute depth values (modulus(z)).
#mean=0.09 # 0.0926
awk '{print $1,$2,sqrt(($3-('$mean'))**2)}' \
   ./grids/britned_seazone_"$grid_size"deg_diff.txt \
   > ./grids/britned_seazone_"$grid_size"deg_diff_abs.txt

# now do the cumulative histogram,
pshistogram ./grids/britned_seazone_"$grid_size"deg_diff_abs.txt \
   $h_proj -R0/8/0/100 -G100/100/100 -W0.25 -L1/0/0/0 -O -P \
   -T2 -Z1 -Q -Y-14 \
   -Ba1f0.5g1:Difference\ \(m\):/a10f2g10:,-%:WeSn \
   >> $hist

# convert the images to jpeg and pdf from postscript
echo -n "converting $outfile to pdf "
ps2pdf -sPAPERSIZE=a4 -dPDFSETTINGS=/prepress -q "$outfile" \
   "${outfile%.ps}.pdf"
ps2pdf -sPAPERSIZE=a4 -dPDFSETTINGS=/prepress -q "$hist" \
   "${hist%.ps}.pdf"
echo -n "and jpeg... "
gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q \
   "-sOutputFile=${outfile%.ps}.jpg" "$outfile"
gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q \
   "-sOutputFile=${hist%.ps}.jpg" "$hist"
echo "done."

exit 0
