#!/bin/bash

# script to plot the interfermometric bathy data from area473 2006.

# i/o
input=./raw_data/area473_2006_lines.txt
#input_deep=./raw_data/bathy_deep.xyz
#input_shoal=./raw_data/bathy_shoal.xyz
#input_gps=./raw_data/area473_2006_gps_tide.txt
outfile=./images/area473_2006.ps
#outfile_gps=./images/area473_2006_gps.ps

# processing parameters
area=-R314494/322135/5.59553e+06/5.59951e+06
proj=-Jx0.0028

# display patameters
a4=-R0/22/0/30
page=-JX22/30

gmtset D_FORMAT %7.9lg
gmtset LABEL_FONT_SIZE 10
gmtset ANNOT_FONT_SIZE 10
gmtset HEADER_FONT_SIZE 14

bm(){
   echo -n "blockmean... "
   #blockmean $input_gps -I2.5 $area > $input_gps.bmd
   #blockmean $input_deep -I2.5 $area > $input_deep.bmd
   #blockmean $input_shoal -I2.5 $area > $input_shoal.bmd
   #blockmean $input_deep $input_shoal -I2.5 $area > ./raw_data/bathy_mean.xyz.bmd
   blockmean $input -I2.5 $area > ./raw_data/`basename $input .txt`.bmd
   echo "done."
}

mksurf(){
   echo -n "surfacing... "
   new_input=./raw_data/`basename $input .txt`.bmd
   # make surfaces
   #surface -Garea473_2006_d_interp.grd -I2.5 $area -T0.25 $input_deep.bmd
   #surface -Garea473_2006_s_interp.grd -I2.5 $area -T0.25 $input_shoal.bmd
   #surface -Garea473_2006_interp.grd -I2.5 $area -T0.25 ./raw_data/bathy_mean.xyz.bmd
   #surface -Garea473_2006_gps_interp.grd -I2.5 $area -T0.25 $input_gps.bmd
   surface -Garea473_2006_interp.grd -I2.5 $area -T0.25 $new_input
   echo "done."
}

mkgrad(){
   echo -n "illuminate... "
   # illuminate those surfaces
   #grdgradient area473_2006_d_interp.grd -A250 -Nt0.7 -Garea473_2006_d_grad.grd
   #grdgradient area473_2006_s_interp.grd -A250 -Nt0.7 -Garea473_2006_s_grad.grd
   grdgradient area473_2006_interp.grd -A250 -Nt0.7 -Garea473_2006_grad.grd
   #grdgradient area473_2006_gps_interp.grd -A250 -Nt0.7 -Garea473_2006_gps_grad.grd
   echo "done."
}

mkmask(){
   echo -n "create mask... "
   # remove interpolated areas from the grid
   grdmask $new_input -Garea473_2006_mask.grd -I2.5 $area -N/NaN/1/1 -S5
   echo "done."
}

maskadd(){
   echo -n "clip grid... "
   #grdmath area473_2006_d_interp.grd area473_2006_mask.grd MUL \
   #   = area473_2006_deep.grd
   #grdmath area473_2006_s_interp.grd area473_2006_mask.grd MUL = \
   #   area473_2006_shoal.grd
   grdmath area473_2006_interp.grd area473_2006_mask.grd MUL = \
      area473_2006.grd
   #grdmath area473_2006_gps_interp.grd area473_2006_mask.grd MUL = \
   #   area473_2006_gps.grd
   echo "done."
}

plot(){
   echo -n "plot the images... "
   # plotting the images
   makecpt -Crainbow -T39.5/46/1 -I -Z > .utec.cpt
   psbasemap $area $proj -Ba1000f500:"Eastings":/a1000f500:"Northings":WeSn -Xc -Yc -K > $outfile
   #psbasemap $area $proj -Ba1000f500:"Eastings":/a1000f500:"Northings":WeSn -Xc -Yc -K > $outfile_gps
   #grdimage $area $proj -Iarea473_2006_d_grad.grd -C.utec.cpt area473_2006_deep.grd -O -K >> $outfile
   #grdimage $area $proj -Iarea473_2006_s_grad.grd -C.utec.cpt area473_2006_shoal.grd -O -K >> $outfile
   grdimage $area $proj -Bg500 -Iarea473_2006_grad.grd -C.utec.cpt \
      area473_2006.grd -O -K >> $outfile
   #grdimage $area $proj -Bg500 -Iarea473_2006_gps_grad.grd -C.utec.cpt area473_2006_gps.grd -O -K >> $outfile_gps
   # add the magic mask outline
   psxy $area $proj -O -K -Sp ../../baseline_difference/grids/outline.xy \
      >> $outfile
   psscale -D22.5/5/-5/0.5 -B1 -C.utec.cpt -O -K >> $outfile
   pstext $proj $area -O -N << TEXT >> $outfile
   322500 5598400 10 0 0 1 Depth (m)
TEXT
   echo "done."
}

conv(){
   echo -n "convert the output... "
   # view the image
   #gs -sPAPERSIZE=a4 $outfile
   ps2pdf -sPAPERSIZE=a4 $outfile ./images/`basename $outfile .ps`.pdf
   #ps2pdf -sPAPERSIZE=a4 $outfile_gps ./images/`basename $outfile_gps .ps`.pdf
   echo "done."
}

#bm                      # blockmean
#mksurf                  # remake the surfaces
#mkgrad                  # calculate the gradients
#mkmask                  # make masks
#maskadd                 # make magic mask
plot                    # plot the grids
conv                    # convert the output

exit 0
