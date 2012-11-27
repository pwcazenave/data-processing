#! /bin/csh

# script to plot the tidal flow direction and magnitude about a point (0,0)

set plot_area=-R-20/20/-20/20
set plot_proj=-JX15
set area_bathy=-R578117/588284/91508/98686
set proj_bathy=-Jx0.22e-2
set area_text=-R0/30/0/22
set proj_text=-JX30c/22c
set outfile=tidal_flow_dir.ps

gmtset LABEL_FONT_SIZE 12
gmtset HEADER_FONT_SIZE 16

# add a basemap
psbasemap $proj_bathy $area_bathy -Ba2000f1000g1000:"Eastings":/a2000f1000g1000:"Northings":WeSn -Xc -Yc -K > $outfile
grdimage $proj_bathy $area_bathy -I../../../bathy/utec_survey/utec/utec_grad.grd -C../../../bathy/utec_survey/utec/utec.cpt ../../../bathy/utec_survey/utec/utec_mask.grd -Bg1000 -O -K >> $outfile

# format the data and convert for the -Sv thing...
awk '{if (NR%3==0) {if ($1<90) print (((360-$1)+90)-360), ($2*5)}}' new_site1_uv.dat > site1_lt_90.dat
awk '{if (NR%3==0) {if ($1>90) print (((360+90)-$1)), ($2*5)}}' new_site1_uv.dat > site1_gt_90.dat
cat site1_lt_90.dat site1_gt_90.dat > site1_input.dat

awk '{if (NR%3==0) {if ($1<90) print (((360-$1)+90)-360), ($2*5)}}' new_site2_uv.dat > site2_lt_90.dat
awk '{if (NR%3==0) {if ($1>90) print (((360+90)-$1)), ($2*5)}}' new_site2_uv.dat > site2_gt_90.dat
cat site2_lt_90.dat site2_gt_90.dat > site2_input.dat

awk '{if (NR%3==0) {if ($1<90) print (((360-$1)+90)-360), ($2*5)}}' new_site3_uv.dat > site3_lt_90.dat
awk '{if (NR%3==0) {if ($1>90) print (((360+90)-$1)), ($2*5)}}' new_site3_uv.dat > site3_gt_90.dat
cat site3_lt_90.dat site3_gt_90.dat > site3_input.dat

# plot the vectors and add white dots for the origin of the vector
awk '{printf "583705 97026 %5s %5s\n", $1, $2, $3, $4}' site1_input.dat > site1_vectors.tmp
psxy $area_bathy $proj_bathy -O -K -G0/0/0 -Sv0.01/0.2/0.05 -V site1_vectors.tmp >> $outfile
awk '{print $1, $2}' site1_vectors.tmp | psxy $area_bathy $proj_bathy -O -K -G255/255/255 -Sc0.1 >> $outfile

awk '{printf "582994 93915 %5s %5s\n", $1, $2, $3, $4}' site3_input.dat > site3_vectors.tmp
psxy $area_bathy $proj_bathy -O -K -G0/0/0 -Sv0.01/0.2/0.05 -V site3_vectors.tmp >> $outfile
awk '{print $1, $2}' site3_vectors.tmp | psxy $area_bathy $proj_bathy -O -K -G255/255/255 -Sc0.1 >> $outfile

awk '{printf "582840 94770 %5s %5s\n", $1, $2, $3, $4}' site2_input.dat > site2_vectors.tmp
psxy $area_bathy $proj_bathy -O -K -G0/0/0 -Sv0.01/0.2/0.05 -V site2_vectors.tmp >> $outfile
awk '{print $1, $2}' site2_vectors.tmp | psxy $area_bathy $proj_bathy -O -K -G255/255/255 -Sc0.1 >> $outfile

# add a scale bar
psscale -D23.3/8/4/0.4 -B5 -C../../../bathy/utec_survey/utec/utec.cpt -O -K >> $outfile
                                                                                
# add labels to the images, and the label to the scale bar using pstext
pstext $proj_text $area_text -O << TEXT >> $outfile
23.0 10.5 12 0.0 1 1 Depth (m)
TEXT

# clean up
\rm -f site2_lt_90.dat site2_gt_90.dat site3_lt_90.dat site3_gt_90.dat site1_lt_90.dat site1_gt_90.dat

# view the image
gs -sPAPERSIZE=a4 $outfile

