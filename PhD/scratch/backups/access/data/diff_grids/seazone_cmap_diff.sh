#!/bin/bash

# script to plot the seazone data and the CMAP data to determine differences
# in the z values

# given the coarsest value (from CMAP)
# CMAP = 1 minute (1x2km)
# SeaZone = 0.002 degress (134x220m) (~0.12minutes)
grid_size=1 # in minutes
gres=-I"$grid_size"m

cmap_in=../cmap/raw_data/corrected_CMAP_bathy.xyz
seazone_in=../seazone/Bathy/gridded_bathy/bathy.xyz
cmap_grid=./grids/cmap_thames_"$grid_size"min.grd
seazone_grid=./grids/seazone_thames_"$grid_size"min.grd
outfile=./images/cmap_seazone_thames.ps
hist=./images/cmap_seazone_histogram.ps

#area=-R-7/5/47.5/53
area=-R-3/3/49.5/52.5
proj=-Jm3.3
h_proj=-JX17/11

gmtset D_FORMAT=%g
gmtset PLOT_DEGREE_FORMAT=F
gmtset LABEL_FONT_SIZE=18
gmtset ANNOT_FONT_SIZE=18

# make grids, not war
#xyz2grd $area $gres -G$cmap_grid $cmap_in
#awk '{if ($3<1) print $1,$2,$3}' $seazone_in | \
#   xyz2grd $area $gres -G$seazone_grid

# make a difference grid
#grdmath $cmap_grid $seazone_grid SUB = \
#   ./grids/cmap_seazone_"$grid_size"min_diff.grd

# make an appropriate colour palette
#grd2cpt $area -Cwysiwyg -L-10/10 \
#   ./grids/cmap_seazone_"$grid_size"mins_diff.grd \
#   > ./cs_diff.cpt
makecpt makecpt -T-6/6/0.1 -Z -Cwysiwyg > ./cs_diff.cpt

# plot the image
grdimage $area $proj ./grids/cmap_seazone_"$grid_size"min_diff.grd \
   -Ba1f0.5g1/a0.5f0.25g0.5WeSn \
   -C./cs_diff.cpt \
   -K -Xc -Yc > $outfile

# add a coastline for the area
pscoast $area $proj -B0WeSn -Df -G0/0/0 -O -K -N1/255/255/255 -W1/255/255/255 >> $outfile

# add the scale in
psscale -D21.8/6.7/6/0.5 -Ba2f1 -C./cs_diff.cpt -O -K >> $outfile
pstext $area $proj -N -O << TEXT >> $outfile
3.2 51.6 18 0 0 1 Difference (m)
TEXT


# do the histograms...
# reset font sizes for histograms since they're full page anyway
gmtset LABEL_FONT_SIZE=12
gmtset ANNOT_FONT_SIZE=12

# create and plot a histogram (frequency and cumulative)
grd2xyz -S ./grids/cmap_seazone_"$grid_size"min_diff.grd \
   > ./grids/cmap_seazone_"$grid_size"min_diff.txt

pshistogram ./grids/cmap_seazone_"$grid_size"min_diff.txt \
   $h_proj -R-12/12/0/8 -G100/100/100 -W0.25 -L1/0/0/0 -K -P \
   -T2 -Z1 -Xc -Y17c \
   -Ba2f1g2:Difference\ \(m\):/a1f0.5g1:,-%:WeSn \
   > $hist

mean=$(
   printf %.2f \
   $(cut -f3 ./grids/cmap_seazone_"$grid_size"min_diff.txt | mean.awk)
   )
stddev=$(
   printf %.2f \
   $(cut -f3 ./grids/cmap_seazone_"$grid_size"min_diff.txt | std_dev.awk)
   )
range=$(
   printf %.2f \
   $(cut -f3 ./grids/cmap_seazone_"$grid_size"min_diff.txt | minmax -C | \
   awk '{print sqrt($1**2)+sqrt($2**2)}')
   )
kurtosis=$(
   printf %.2f \
   $(cut -f3 ./grids/cmap_seazone_"$grid_size"min_diff.txt | \
   stat_moments.awk | \
   grep kurtosis | cut -f2 -d":")
   )
pstext -J -R -O -K -N -W255/255/255 << STATS >> $hist
-11.7 7.6 10 0 0 1 Standard deviation = ${stddev}m
-11.7 7.2 10 0 0 1 Mean = ${mean}m
-11.7 6.8 10 0 0 1 Range = ${range}m
-11.7 6.4 10 0 0 1 Kurtosis = ${kurtosis}m
STATS

# remove the modal value from the difference grid output (-1.7939m) before \
# getting absolute depth values (modulus(z)).
#mean=0.09 # 0.0926
awk '{print $1,$2,sqrt(($3-('$mean'))**2)}' \
   ./grids/cmap_seazone_"$grid_size"min_diff.txt \
   > ./grids/cmap_seazone_"$grid_size"min_diff_abs.txt

# now do the cumulative histogram,
pshistogram ./grids/cmap_seazone_"$grid_size"min_diff_abs.txt \
   $h_proj -R0/12/0/100 -G100/100/100 -W0.25 -L1/0/0/0 -O -P \
   -T2 -Z1 -Q -Y-14 \
   -Ba1f0.5g1:Difference\ \(m\):/a10f2g10:,-%:WeSn \
   >> $hist

# convert the images to jpeg and pdf from postscript
echo -n "converting images to pdf "
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
