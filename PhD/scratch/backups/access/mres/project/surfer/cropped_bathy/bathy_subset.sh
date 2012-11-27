#! /bin/csh

# script to illuminate and plot the cropped bathy for Justin

#set plot_area=-R578117.5/586476.5/91508.5/95000
set proc_area=-R578113.01/588285.095/91508.5/98685.64
set plot_proj=-Jx1e-2
set area_text=-R0/83/0/55
set proj_text=-JX130/55
set outfile=southern_bathy.ps

gmtset LABEL_FONT_SIZE 30
gmtset HEADER_FONT_SIZE 42
gmtset ANNOT_FONT_SIZE_PRIMARY 26

# increase decimal places to 10
gmtset D_FORMAT %.10lf

## preprocessing

# convert the gmt 2m bathy grid file (utec_mask.grd) into a surfer compatible one:
#grdreformat ../../bathy/utec_survey/utec/utec_mask.grd bathy.grd=sf $proc_area -V

# OR:

# convert the surfer grid file into a gmt grid file
#grdreformat cropped_bathy.grd=sf gmt_bathy.grd $proc_area -V
# didn't preserve the aspect ratio correctly though...

## processing

# use the output from surfer after the data have been blanked to cover over the area of interest and make a gridfile
#grep -v E cropped_bathy.xyz | xyz2grd $proc_area -Ggmt_bathy.grd -I5 -V
#xyz2grd $proc_area -Ggmt_bathy.grd cropped_bathy.xyz -I5 -V

# in order to reveal the bedforms, need to illuminate them, therefore need to apply grdgradient first, then use the -I flag in grdimage to show it from a particular angle.
#grdgradient -V gmt_bathy.grd -A250 -Nt0.7 -Ggmt_grad.grd

# return decimal places to zero
gmtset D_FORMAT %.0lf

## display

# plot that bathy file (final_bathy.grd)
psbasemap $plot_proj $proc_area -Ba1000f500:"Eastings":/a1000f500:"Northings":WeSn -X10 -Y-57 -K > $outfile

#grdimage final_bathy.grd $plot_proj $proc_area -O -K -Cutec.cpt -Igmt_grad.grd -Bg500 >> $outfile
grdimage ../../bathy/utec_survey/utec/utec_mask.grd $plot_proj $proc_area -O -K -C../../bathy/utec_survey/utec/utec.cpt -I../../bathy/utec_survey/utec/utec_grad.grd >> $outfile
psxy $proc_area $plot_proj north_blank.bln -G128/128/128 -O -K >> $outfile

#grdimage gmt_bathy.grd $plot_proj $proc_area -O -K -Cutec.cpt -Bg500 >> $outfile

# add the grid lines back over the psxy plot
psbasemap $plot_proj $proc_area -Bg500 -O -K >> $outfile

# add a scale
psscale -D104/35/15/1 -B5 -Cutec.cpt -O -K >> $outfile

# add some text
# add labels to the images, and the label to the scale bar using pstext
pstext $proj_text $area_text -O << TEXT >> $outfile
66 43.3 24 0.0 1 1 Depth (m)
TEXT


# display the image
gs -sPAPERSIZE=a0 $outfile
