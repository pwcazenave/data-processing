#!/bin/csh -f
#
# Shellscript to create Postscript plot of swath sonar data
# Created by macro mbm_plot
#
# This shellscript created by following command line:
# mbm_plot -F-1 -I datalist.mb-1 -C -G5
#
# Define shell variables used in this script:
set PS_FILE         = ./images/sidescan_plot.ps
set CPT_FILE        = sss.cpt
set MAP_PROJECTION  = m
set MAP_SCALE       = 3
set MAP_REGION      = -10/5/47/52.5
set X_OFFSET        = 1
set Y_OFFSET        = 2.5523
set INPUT_FILE      = ./raw_data/new_list.mb_1
set INPUT_FORMAT    = -1
#
# Save existing GMT defaults
echo Saving GMT defaults...
gmtdefaults -L > gmtdefaults$$
#
# Set new GMT defaults
echo Setting new GMT defaults...
gmtset MEASURE_UNIT inch
gmtset PAPER_MEDIA A0
gmtset ANOT_FONT Helvetica
gmtset LABEL_FONT Helvetica
gmtset HEADER_FONT Helvetica
gmtset ANOT_FONT_SIZE 8
gmtset LABEL_FONT_SIZE 8
gmtset HEADER_FONT_SIZE 10
gmtset FRAME_WIDTH 0.075
gmtset TICK_LENGTH 0.075
gmtset PAGE_ORIENTATION LANDSCAPE
gmtset COLOR_BACKGROUND 0/0/0
gmtset COLOR_FOREGROUND 255/255/255
gmtset COLOR_NAN 255/255/255
gmtset PLOT_DEGREE_FORMAT ddd:mm
#
# Make color pallette table file
echo Making color pallette table file...
echo      0 255 255 255     35 230 230 230 >! $CPT_FILE
echo     35 230 230 230     70 204 204 204 >> $CPT_FILE
echo     70 204 204 204    105 179 179 179 >> $CPT_FILE
echo    105 179 179 179    140 153 153 153 >> $CPT_FILE
echo    140 153 153 153    175 128 128 128 >> $CPT_FILE
echo    175 128 128 128    210 102 102 102 >> $CPT_FILE
echo    210 102 102 102    245  77  77  77 >> $CPT_FILE
echo    245  77  77  77    280  51  51  51 >> $CPT_FILE
echo    280  51  51  51    315  26  26  26 >> $CPT_FILE
echo    315  26  26  26    350   0   0   0 >> $CPT_FILE
#
# Make basemap
echo Running psbasemap...
psbasemap -J$MAP_PROJECTION$MAP_SCALE \
	-R$MAP_REGION \
	-Ba2f1g2:."Data List File $INPUT_FILE": \
	-Xc -Yc -K > $PS_FILE
#
# Run mbswath
echo Running mbswath...
mbswath -f-1 -I$INPUT_FILE \
	-J$MAP_PROJECTION$MAP_SCALE \
	-R$MAP_REGION \
	-C$CPT_FILE \
	-Z5 \
	-A2/1/100 \
	-p1 \
        -Q300 \
	-O -K -V >> $PS_FILE
#
# Run mbcontour
#echo Running mbcontour...
#mbcontour -f-1 -I$INPUT_FILE \
#	-J$MAP_PROJECTION$MAP_SCALE \
#	-R$MAP_REGION \
#	-A500/100000/100000/100000/0.011/0.11 \
#	-p1 \
#	-K -O -V >> $PS_FILE
#
# Make basemap
echo Running psbasemap...
psbasemap -J$MAP_PROJECTION$MAP_SCALE \
	-R$MAP_REGION \
	-Ba2f1g2:."Data List File $INPUT_FILE": \
	-O -K >> $PS_FILE
#
# Make color scale
gmtset D_FORMAT %g
echo Running psscale...
psscale -C$CPT_FILE \
	-D3.2500/-0.5000/6.5000/0.1500h \
	-B":Sidescan Pixel Values:" \
	-O -K >> $PS_FILE
#
# Add a coastline
echo Adding a coastline...
pscoast -R$MAP_REGION -J$MAP_PROJECTION$MAP_SCALE \
        -B0 -Df \
        -G0/0/0 \
        -O \
        -N1/255/255/255 \
        -W1/255/255/255 >> $PS_FILE
#
# Delete surplus files
echo Deleting surplus files...
/bin/rm -f $CPT_FILE
#
# Reset GMT default fonts
echo Resetting GMT fonts...
/bin/mv gmtdefaults$$ .gmtdefaults
#
# Run ghostview
echo Make a pdf...
ps2pdf -sPAPERSIZE=a0 $PS_FILE ./images/`basename $PS_FILE .ps`.pdf
echo Running ghostview in background...
gs -sPAPERSIZE=a0 $PS_FILE
#
# All done!
echo All done!
