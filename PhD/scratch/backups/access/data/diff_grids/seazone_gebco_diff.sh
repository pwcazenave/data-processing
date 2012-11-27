#!/bin/bash

# script to plot the seazone data and the CMAP data to determine differences
# in the z values

# given the coarsest value (from CMAP)
# GEBCO = 1 minute (1x2km)
# SeaZone = 0.002 degress (134x220m) (~0.12minutes)
grid_size=1 # in minutes
gres=-I"$grid_size"m

gebco_in=../gebco/plot/raw_data/gebco_channel.xyz
seazone_in=../seazone/Bathy/gridded_bathy/bathy.xyz
gebco_grid=./grids/gebco_thames_"$grid_size"min.grd
seazone_grid=./grids/seazone_thames_"$grid_size"min.grd
outfile=./images/gebco_seazone_thames.ps
fft_outfile=./images/gebco_seazone_thames_fft.ps
hist=./images/gebco_seazone_histogram.ps
fhist=./images/gebco_seazone_histogram_fft.ps

#area=-R-7/5/47.5/53
area=-R-3/3/49.5/52.5
proj=-Jm3.3
h_proj=-JX17/11

gmtset D_FORMAT=%g
gmtset PLOT_DEGREE_FORMAT=F
gmtset LABEL_FONT_SIZE=18
gmtset ANNOT_FONT_SIZE=18

#set -ex

# make grids, not war
#xyz2grd $area $gres -G$gebco_grid $gebco_in
#awk '{if ($3<1) print $1,$2,$3}' $seazone_in | \
#   xyz2grd $area $gres -G$seazone_grid
# make a surface for the fft (can't deal with NaNs)
#surface $area $gebco_in $gres -T0.25 \
#   -G${gebco_grid%.grd}_surface.grd

# fft filter the gebco grid
grdfft ${gebco_grid%.grd}_surface.grd -G${gebco_grid%.grd}_fft.grd \
   -L -F-/-/40000/20000 -M

# make a difference grid
#grdmath $gebco_grid $seazone_grid SUB = \
#   ./grids/gebco_seazone_"$grid_size"min_diff.grd
grdmath ${gebco_grid%.grd}_fft.grd $seazone_grid SUB = \
   ./grids/gebco_seazone_"$grid_size"min_diff_fft.grd

# make an appropriate colour palette
#grd2cpt $area -Cwysiwyg -L-10/10 \
#   ./grids/gebco_seazone_"$grid_size"mins_diff.grd \
#   > ./cs_diff.cpt
makecpt makecpt -T-10/10/0.1 -Z -Cwysiwyg > ./gs_diff.cpt

# plot the image
grdimage $area $proj ./grids/gebco_seazone_"$grid_size"min_diff.grd \
   -Ba1f0.5g1/a0.5f0.25g0.5WeSn \
   -C./gs_diff.cpt \
   -K -Xc -Yc > $outfile
grdimage $area $proj ./grids/gebco_seazone_"$grid_size"min_diff_fft.grd \
   -Ba1f0.5g1/a0.5f0.25g0.5WeSn \
   -C./gs_diff.cpt \
   -K -Xc -Yc > $fft_outfile

# add a coastline for the area
pscoast $area $proj -B0WeSn -Df -G0/0/0 -O -K -N1/255/255/255 -W1/255/255/255 >> $outfile
pscoast $area $proj -B0WeSn -Df -G0/0/0 -O -K -N1/255/255/255 -W1/255/255/255 >> $fft_outfile

# add the scale in
psscale -D21.8/6.7/6/0.5 -Ba5f1 -C./gs_diff.cpt -O -K >> $outfile
pstext $area $proj -N -O << TEXT >> $outfile
3.2 51.6 18 0 0 1 Difference (m)
TEXT
psscale -D21.8/6.7/6/0.5 -Ba5f1 -C./gs_diff.cpt -O -K >> $fft_outfile
pstext $area $proj -N -O << TEXT >> $fft_outfile
3.2 51.6 18 0 0 1 Difference (m)
TEXT

# make histograms, not war
# reset font sizes for histograms since they're full page anyway
gmtset LABEL_FONT_SIZE=12
gmtset ANNOT_FONT_SIZE=12

# create and plot a histogram (frequency and cumulative)
grd2xyz -S ./grids/gebco_seazone_"$grid_size"min_diff.grd \
   > ./grids/gebco_seazone_"$grid_size"min_diff.txt

pshistogram ./grids/gebco_seazone_"$grid_size"min_diff.txt \
   $h_proj -R-20/20/0/3 -G100/100/100 -W0.25 -L1/0/0/0 -K -P \
   -T2 -Z1 -Xc -Y17c \
   -Ba5f1g5:Difference\ \(m\):/a0.5f0.1g0.5:,-%:WeSn \
   > $hist

mean=$(
   printf %.2f \
   $(cut -f3 ./grids/gebco_seazone_"$grid_size"min_diff.txt | mean.awk)
   )
stddev=$(
   printf %.2f \
   $(cut -f3 ./grids/gebco_seazone_"$grid_size"min_diff.txt | std_dev.awk)
   )
range=$(
   printf %.2f \
   $(cut -f3 ./grids/gebco_seazone_"$grid_size"min_diff.txt | minmax -C | \
   awk '{print sqrt($1**2)+sqrt($2**2)}')
   )
kurtosis=$(
   printf %.2f \
   $(cut -f3 ./grids/gebco_seazone_"$grid_size"min_diff.txt | \
   stat_moments.awk | \
   grep kurtosis | cut -f2 -d":")
   )
pstext -J -R -O -K -N -W255/255/255 << STATS >> $hist
-19 2.85 10 0 0 1 Standard deviation = ${stddev}m
-19 2.7 10 0 0 1 Mean = ${mean}m
-19 2.55 10 0 0 1 Range = ${range}m
-19 2.4 10 0 0 1 Kurtosis = ${kurtosis}m
STATS

# remove the modal value from the difference grid output (-1.7939m) before \
# getting absolute depth values (modulus(z)).
#mean=0.09 # 0.0926
awk '{print $1,$2,sqrt(($3-('$mean'))**2)}' \
   ./grids/gebco_seazone_"$grid_size"min_diff.txt \
   > ./grids/gebco_seazone_"$grid_size"min_diff_abs.txt

# now do the cumulative histogram,
pshistogram ./grids/gebco_seazone_"$grid_size"min_diff_abs.txt \
   $h_proj -R0/20/0/100 -G100/100/100 -W0.25 -L1/0/0/0 -O -P \
   -T2 -Z1 -Q -Y-14 \
   -Ba2f0.5g2:Difference\ \(m\):/a10f2g10:,-%:WeSn \
   >> $hist


# create and plot a histogram (frequency and cumulative) for filtered grid
grd2xyz -S ./grids/gebco_seazone_"$grid_size"min_diff_fft.grd \
   > ./grids/gebco_seazone_"$grid_size"min_diff_fft.txt

pshistogram ./grids/gebco_seazone_"$grid_size"min_diff_fft.txt \
   $h_proj -R-20/20/0/3 -G100/100/100 -W0.25 -L1/0/0/0 -K -P \
   -T2 -Z1 -Xc -Y17c \
   -Ba5f1g5:Difference\ \(m\):/a0.5f0.1g0.5:,-%:WeSn \
   > $fhist

fmean=$(
   printf %.2f \
   $(cut -f3 ./grids/gebco_seazone_"$grid_size"min_diff_fft.txt | mean.awk)
   )
fstddev=$(
   printf %.2f \
   $(cut -f3 ./grids/gebco_seazone_"$grid_size"min_diff_fft.txt | std_dev.awk)
   )
frange=$(
   printf %.2f \
   $(cut -f3 ./grids/gebco_seazone_"$grid_size"min_diff_fft.txt | minmax -C | \
   awk '{print sqrt($1**2)+sqrt($2**2)}')
   )
fkurtosis=$(
   printf %.2f \
   $(cut -f3 ./grids/gebco_seazone_"$grid_size"min_diff_fft.txt | \
   stat_moments.awk | \
   grep kurtosis | cut -f2 -d":")
   )
pstext -J -R -O -K -N -W255/255/255 << STATS >> $fhist
-19 2.85 10 0 0 1 Standard deviation = ${fstddev}m
-19 2.7 10 0 0 1 Mean = ${fmean}m
-19 2.55 10 0 0 1 Range = ${frange}m
-19 2.4 10 0 0 1 Kurtosis = ${fkurtosis}m
STATS

# remove the modal value from the difference grid output (-1.7939m) before \
# getting absolute depth values (modulus(z)).
#mean=0.09 # 0.0926
awk '{print $1,$2,sqrt(($3-('$fmean'))**2)}' \
   ./grids/gebco_seazone_"$grid_size"min_diff_fft.txt \
   > ./grids/gebco_seazone_"$grid_size"min_diff_fft_abs.txt

# now do the cumulative histogram,
pshistogram ./grids/gebco_seazone_"$grid_size"min_diff_fft_abs.txt \
   $h_proj -R0/20/0/100 -G100/100/100 -W0.25 -L1/0/0/0 -O -P \
   -T2 -Z1 -Q -Y-14 \
   -Ba2f0.5g2:Difference\ \(m\):/a10f2g10:,-%:WeSn \
   >> $fhist

# convert the images to jpeg and pdf from postscript
echo -n "converting output images to pdf "
ps2pdf -sPAPERSIZE=a4 -dPDFSETTINGS=/prepress -q "$outfile" \
   "${outfile%.ps}.pdf"
ps2pdf -sPAPERSIZE=a4 -dPDFSETTINGS=/prepress -q "$fft_outfile" \
   "${fft_outfile%.ps}.pdf"
ps2pdf -sPAPERSIZE=a4 -dPDFSETTINGS=/prepress -q "$hist" \
   "${hist%.ps}.pdf"
ps2pdf -sPAPERSIZE=a4 -dPDFSETTINGS=/prepress -q "$fhist" \
   "${fhist%.ps}.pdf"
echo -n "and jpeg... "
gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q \
   "-sOutputFile=${outfile%.ps}.jpg" "$outfile"
gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q \
   "-sOutputFile=${fft_outfile%.ps}.jpg" "$fft_outfile"
gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q \
   "-sOutputFile=${hist%.ps}.jpg" "$hist"
gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q \
   "-sOutputFile=${fhist%.ps}.jpg" "$fhist"
echo "done."

exit 0
