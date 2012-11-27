#!/bin/bash

# script to plot the difference grids for GEBCO and CMAP data at 1km resolution

if [[ -d ./images ]] || [[ -d ./grids ]]; then
   mkdir images grids 2>/dev/null
fi

grid_size=2000 # in metres
gres=-I"$grid_size"e

cmap_in=../cmap/raw_data/corrected_CMAP_bathy.xyz
gebco_in=../gebco/plot/raw_data/gebco_channel.xyz
cmap_grid=./grids/cmap_bathy_"$grid_size"m.grd
gebco_grid=./grids/gebco_bathy_"$grid_size"m.grd
outfile=./images/cmap_gebco_diff.ps
hist=./images/cmap_gebco_histogram.ps
hist_cmap=./images/cmap_percentage_diff_histogram.ps
hist_gebco=./images/gebco_percentage_diff_histogram.ps
pc_cmap=./images/cmap_percentage_diff_plot.ps
pc_gebco=./images/gebco_percentage_diff_plot.ps

area=-R-7/5/47.5/53
proj=-Jm1.6
h_proj=-JX17/11

gmtset D_FORMAT=%g
gmtset PLOT_DEGREE_FORMAT F
gmtset LABEL_FONT_SIZE=18
gmtset ANNOT_FONT_SIZE=18

# make grids, not war
xyz2grd $area $gres -G$cmap_grid $cmap_in
xyz2grd $area $gres -G$gebco_grid $gebco_in
##grdsample $cmap_grid -I1000e -G./grids/cmap_1k.grd
##grdsample $gebco_grid -I1000e -G./grids/gebco_1k.grd

# make a difference grid
grdmath ./grids/cmap_bathy_"$grid_size"m.grd \
   ./grids/gebco_bathy_"$grid_size"m.grd SUB = \
   ./grids/cmap_gebco_"$grid_size"m_diff.grd

# make an appropriate colour palette
makecpt makecpt -T-20/20/0.1 -Z -Cwysiwyg > ./cg_diff.cpt

# plot the image
grdimage $area $proj ./grids/cmap_gebco_"$grid_size"m_diff.grd \
   -Ba1f0.5g1WeSn \
   -C./cg_diff.cpt \
   -K -Xc -Yc > $outfile

# add a coastline for the area
pscoast $area $proj -Ba5f2.5g5WeSn -Df -G0/0/0 -O -K -N1/255/255/255 -W1/255/255/255 >> $outfile

# add the scale in
psscale -D21.2/6/6/0.5 -Ba10f2 -C./cg_diff.cpt -O -K >> $outfile
pstext $area $proj -N -O << TEXT >> $outfile
5.4 51.6 18 0 0 1 Difference (m)
TEXT

# reset font sizes for histograms since they're full page anyway
gmtset LABEL_FONT_SIZE=12
gmtset ANNOT_FONT_SIZE=12

# create and plot a histogram (frequency and cumulative)
grd2xyz -S ./grids/cmap_gebco_"$grid_size"m_diff.grd \
   > ./grids/cmap_gebco_"$grid_size"m_diff.txt

pshistogram ./grids/cmap_gebco_"$grid_size"m_diff.txt \
   $h_proj -R-20/20/0/4 -G100/100/100 -W0.25 -L1/0/0/0 -K -P \
   -T2 -Z1 -Xc -Y17c \
   -Ba5f1g5:Difference\ \(m\):/a0.5f0.1g0.5:,-%:WeSn \
   > $hist

mean=$(
   printf %.2f \
   $(cut -f3 ./grids/cmap_gebco_"$grid_size"m_diff.txt | mean.awk)
   )
stddev=$(
   printf %.2f \
   $(cut -f3 ./grids/cmap_gebco_"$grid_size"m_diff.txt | std_dev.awk )
   )
range=$(
   printf %.2f \
   $(cut -f3 ./grids/cmap_gebco_"$grid_size"m_diff.txt | minmax -C | \
   awk '{print sqrt($1**2)+sqrt($2**2)}')
   )
kurtosis=$(
   printf %.2f \
   $(cut -f3 ./grids/cmap_gebco_"$grid_size"m_diff.txt | \
   stat_moments.awk | \
   grep kurtosis | cut -f2 -d":")
   )
pstext -J -R -O -K -N -W255/255/255 << STATS >> $hist
-19 3.8 10 0 0 1 Standard deviation = ${stddev}m
-19 3.6 10 0 0 1 Mean = ${mean}m
-19 3.4 10 0 0 1 Range = ${range}m
-19 3.2 10 0 0 1 Kurtosis = ${kurtosis}m
STATS

# remove the mean value from the difference grid output before \
# getting absolute depth values (modulus(z)).
#mean=-2.13 # -2.1297 #-1.7939
awk '{print $1,$2,sqrt(($3-('$mean'))**2)}' \
   ./grids/cmap_gebco_"$grid_size"m_diff.txt \
   > ./grids/cmap_gebco_"$grid_size"m_diff_abs.txt

# now do the cumulative histogram,
pshistogram ./grids/cmap_gebco_"$grid_size"m_diff_abs.txt \
   $h_proj -R0/20/0/100 -G100/100/100 -W0.25 -L1/0/0/0 -O -K -P \
   -T2 -Z1 -Q -Y-14 \
   -Ba2f0.5g2:Difference\ \(m\):/a10f2g10:,-%:WeSn \
   >> $hist




# make difference grids where the difference is expressed as a percentage
# of the water depth
# relative to cmap
grdmath \
   ./grids/cmap_gebco_"$grid_size"m_diff.grd \
   ./grids/cmap_bathy_"$grid_size"m.grd \
   DIV \
   100 MUL \
   = ./grids/cmap_diff_${grid_size}m_percent.grd
# relative to gebco
grdmath \
   ./grids/cmap_gebco_"$grid_size"m_diff.grd \
   ./grids/gebco_bathy_"$grid_size"m.grd \
   DIV \
   100 MUL \
   = ./grids/gebco_diff_${grid_size}m_percent.grd

# now do the histograms of those files
grd2xyz -S ./grids/cmap_diff_${grid_size}m_percent.grd \
   > ./grids/cmap_diff_"$grid_size"m_percent.txt
grd2xyz -S ./grids/gebco_diff_${grid_size}m_percent.grd \
   > ./grids/gebco_diff_"$grid_size"m_percent.txt

# normal frequency histograms (relative to cmap)
pshistogram ./grids/cmap_diff_"$grid_size"m_percent.txt \
   $h_proj -R-100/100/0/3 -G100/100/100 -W0.5 -L1/0/0/0 -P \
   -T2 -Z1 -Xc -Y17c -K \
   -Ba20f10g20:Difference\ \(%\):/a0.5f0.1g0.5:,-%:WeSn \
   > $hist_cmap

cmean=$(
   printf %.2f \
   $(cut -f3 ./grids/cmap_diff_"$grid_size"m_percent.txt | mean.awk)
   )
cstddev=$(
   printf %.2f \
   $(cut -f3 ./grids/cmap_diff_"$grid_size"m_percent.txt | std_dev.awk )
   )
pstext -J -R -O -K -N -W255/255/255 << STDDEV >> $hist_cmap
-95 2.8 10 0 0 1 Standard deviation=${cstddev}%
-95 2.6 10 0 0 1 Mean=${cmean}%
STDDEV

# relative to gebco
pshistogram ./grids/gebco_diff_"$grid_size"m_percent.txt \
   $h_proj -R-100/100/0/3 -G100/100/100 -W0.5 -L1/0/0/0 -P \
   -T2 -Z1 -Xc -Y17c -K \
   -Ba20f10g20:Difference\ \(%\):/a0.5f0.1g0.5:,-%:WeSn \
   > $hist_gebco

gmean=$(
   printf %.2f \
   $(cut -f3 ./grids/gebco_diff_"$grid_size"m_percent.txt | mean.awk)
   )
gstddev=$(
   printf %.2f \
   $(cut -f3 ./grids/gebco_diff_"$grid_size"m_percent.txt | std_dev.awk )
   )
pstext -J -R -O -K -N -W255/255/255 << STDDEV >> $hist_gebco
-95 2.8 10 0 0 1 Standard deviation=${gstddev}%
-95 2.6 10 0 0 1 Mean=${gmean}%
STDDEV

# remove the mean value from the difference grid output before getting
# absolute depth values (modulus(z)).
#mean=1.328
# now do the cumulative histogram relative to cmap
awk '{print $1,$2,sqrt(($3-('$cmean'))**2)}' \
   ./grids/cmap_diff_"$grid_size"m_percent.txt \
   > ./grids/cmap_diff_"$grid_size"m_percent_abs.txt
pshistogram ./grids/cmap_diff_"$grid_size"m_percent_abs.txt \
   $h_proj -R0/100/0/100 -G100/100/100 -W0.25 -L1/0/0/0 -O -K -P \
   -T2 -Z1 -Q -Y-14 \
   -Ba10f2g10:Percentage\ difference:/a10f2g10:,-%:WeSn \
   >> $hist_cmap

# now do the cumulative histogram relative to gebco
awk '{print $1,$2,sqrt(($3-('$gmean'))**2)}' \
   ./grids/gebco_diff_"$grid_size"m_percent.txt \
   > ./grids/gebco_diff_"$grid_size"m_percent_abs.txt
pshistogram ./grids/gebco_diff_"$grid_size"m_percent_abs.txt \
   $h_proj -R0/100/0/100 -G100/100/100 -W0.25 -L1/0/0/0 -O -K -P \
   -T2 -Z1 -Q -Y-14 \
   -Ba10f2g10:Percentage\ difference:/a10f2g10:,-%:WeSn \
   >> $hist_gebco

# get font sizes right
gmtset LABEL_FONT_SIZE=18
gmtset ANNOT_FONT_SIZE=18

# plot the percent grids to check spatial distribution
makecpt -T-100/100/0.1 -Z -Cwysiwyg > ./pc_diff.cpt
grdimage $area $proj ./grids/cmap_diff_"$grid_size"m_percent.grd \
   -Ba1f0.5g1WeSn \
   -C./pc_diff.cpt \
   -K -Xc -Yc > $pc_cmap
   #-Ba1f0.5g1:."Percentage depth difference relative to C-MAP":WeSn \
pscoast $area $proj -Ba5f2.5g5WeSn -Df -G0/0/0 -O -K -N1/255/255/255 -W1/255/255/255 >> $pc_cmap
psscale -D20.9/6/6/0.5 -Ba30f10 -C./pc_diff.cpt -O -K >> $pc_cmap
pstext $area $proj -N -O << TEXT >> $pc_cmap
5.4 51.6 18 0 0 1 Difference (%)
TEXT

grdimage $area $proj ./grids/gebco_diff_"$grid_size"m_percent.grd \
   -Ba1f0.5g1WeSn \
   -C./pc_diff.cpt \
   -K -Xc -Yc > $pc_gebco
   #-Ba1f0.5g1:."Percentage depth difference relative to GEBCO":WeSn \
pscoast $area $proj -Ba5f2.5g5WeSn -Df -G0/0/0 -O -K -N1/255/255/255 -W1/255/255/255 >> $pc_gebco
psscale -D20.9/6/6/0.5 -Ba30f10 -C./pc_diff.cpt -O -K >> $pc_gebco
pstext $area $proj -N -O << TEXT >> $pc_gebco
5.4 51.6 18 0 0 1 Difference (%)
TEXT

# convert the images to jpeg and pdf from postscript
echo -n "converting to pdf "
ps2pdf -sPAPERSIZE=a4 -dPDFSETTINGS=/prepress -q "$outfile" \
   "${outfile%.ps}.pdf"
ps2pdf -sPAPERSIZE=a4 -dPDFSETTINGS=/prepress -q "$pc_cmap" \
   "${pc_cmap%.ps}.pdf"
ps2pdf -sPAPERSIZE=a4 -dPDFSETTINGS=/prepress -q "$pc_gebco" \
   "${pc_gebco%.ps}.pdf"
ps2pdf -sPAPERSIZE=a4 -dPDFSETTINGS=/prepress -q "$hist_cmap" \
   "${hist_cmap%.ps}.pdf"
ps2pdf -sPAPERSIZE=a4 -dPDFSETTINGS=/prepress -q "$hist_gebco" \
   "${hist_gebco%.ps}.pdf"
ps2pdf -sPAPERSIZE=a4 -dPDFSETTINGS=/prepress -q "$hist" \
   "${hist%.ps}.pdf"
echo -n "and jpeg... "
gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q \
   "-sOutputFile=${outfile%.ps}.jpg" "$outfile"
gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q \
   "-sOutputFile=${pc_cmap%.ps}.jpg" "$pc_cmap"
gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q \
   "-sOutputFile=${pc_gebco%.ps}.jpg" "$pc_gebco"
gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q \
   "-sOutputFile=${hist_cmap%.ps}.jpg" "$hist_cmap"
gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q \
   "-sOutputFile=${hist_gebco%.ps}.jpg" "$hist_gebco"
gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q \
   "-sOutputFile=${hist%.ps}.jpg" "$hist"
echo "done."

exit 0
