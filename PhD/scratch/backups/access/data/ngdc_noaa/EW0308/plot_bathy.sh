#! /bin/csh -f
#
# Shellscript to create Postscript plot of swath sonar data
# Created by macro mbm_plot
#
# This shellscript created by following command line:
# mbm_plot -F-1 -I ./new_list.mb_1 -G2
#
# Define shell variables used in this script:
set PS_FILE         = ./images/channel_bathy.ps
set CPT_FILE        = bathy.cpt
set MAP_PROJECTION  = m
set MAP_SCALE       = 35
set MAP_REGION      = 0/1/50.5/51
set X_OFFSET        = 1
set Y_OFFSET        = 2.024
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
gmtset PAPER_MEDIA a0
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
echo      0 255 255 255    500 255 186 133 >! $CPT_FILE
echo    500 255 186 133   1000 255 161  68 >> $CPT_FILE
echo   1000 255 161  68   1500 255 189  87 >> $CPT_FILE
echo   1500 255 189  87   2000 240 236 121 >> $CPT_FILE
echo   2000 240 236 121   2500 205 255 162 >> $CPT_FILE
echo   2500 205 255 162   3000 138 236 174 >> $CPT_FILE
echo   3000 138 236 174   3500 106 235 255 >> $CPT_FILE
echo   3500 106 235 255   4000  50 190 255 >> $CPT_FILE
echo   4000  50 190 255   4500  40 127 251 >> $CPT_FILE
echo   4500  40 127 251   5000  37  57 175 >> $CPT_FILE
#
# Make basemap
echo Running psbasemap...
psbasemap -J$MAP_PROJECTION$MAP_SCALE \
	-R$MAP_REGION \
	-Ba0.5f0.25g0.5:."Data List File $INPUT_FILE": \
	-Xc -Yc -K > $PS_FILE
#
# Run mbswath
#echo Running mbswath...
#mbswath -f-1 -I$INPUT_FILE \
#	-J$MAP_PROJECTION$MAP_SCALE \
#	-R$MAP_REGION \
#	-C$CPT_FILE \
#	-Z2 \
#	-A2/1/100 \
#	-G2.5/0 \
#	-p1 \
#	-O -K -V >> $PS_FILE
#
# Make color scale
echo Running psscale...
psscale -C$CPT_FILE \
	-D4.5000/-0.5000/9.0000/0.1500h \
	-B":Depth (meters):" \
	-K -O -V >> $PS_FILE
#
# Make basemap
echo Running psbasemap...
psbasemap -J$MAP_PROJECTION$MAP_SCALE \
	-R$MAP_REGION \
	-Bg0.5:."Data List File $INPUT_FILE": \
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
echo Running gs...
gs -sPAPERSIZE=a0 $PS_FILE
#
# All done!
echo All done!
