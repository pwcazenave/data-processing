#!/bin/bash

# script to process and plot the raw, semi-processed bathy data from the
# UTEC/Hanson 2005 area473 eastern english channel survey.

roll(){
   input=./raw_data/roll_corrected_bathy.txt
   outfile=./images/bathy_roll.ps
}

qloud(){
   input=./raw_data/qloud_ouput.txt
   outfile=./images/bathy_qloud.ps
}

cleaned(){
   input=./raw_data/area473_2005_cleaned.txt
   outfile=./images/bathy_cleaned.ps
}

hastings(){
   input=./raw_data/area473_2005_hastings_tide.txt
   outfile=./images/bathy_hastings_correction.ps
}

gmtset D_FORMAT %7.9lg
gmtset LABEL_FONT_SIZE 10
gmtset ANNOT_FONT_SIZE 10
gmtset HEADER_FONT_SIZE 14

area=-R313600/323268/5.59500e+06/5.59995e+06
proj=-Jx0.0023

bm(){
   echo -n "blockmean... "
      blockmedian -I1 $area $input > ${input%.txt}.bmd
   echo "done."
}

mksurf(){
   echo -n "surface... "
   surface -G"$name"_interp.grd -I1 $area -T0.25 \
      ${input%.txt}.bmd
   echo "done."
}

mkgrad(){
   echo -n "make gradient grids... "
   # illuminate those surfaces
   grdgradient "$name"_interp.grd -A250 -Nt0.7 \
      -G"$name"_grad.grd
   echo "done."
}

mkmask(){
   echo -n "make masks... "
   grdmask -G"$name"_mask.grd -I1 $area -N/NaN/1/1 -S5 \
      ${input%.txt}.bmd
   echo "done."
}

clip(){
   echo -n "clip the interpolated grids... "
   grdmath "$name"_interp.grd "$name"_mask.grd \
      MUL = "$name".grd
   echo "done."
}

plot(){
   echo -n "plot the image... "
#   makecpt -Crainbow -T-49/-39/1 -Z > .utec_r.cpt
   makecpt -Crainbow -T39/49/1 -I -Z > .utec_cleaned.cpt
   #makecpt -Cwysiwyg -T-49/-38/1 -Z > .utec_q.cpt
   grdimage $area $proj \
      -Ba2000f1000g1000:"Eastings":/a1000f500g1000:"Northings":WeSn \
      -I"$name"_grad.grd -C.utec_cleaned.cpt \
      "$name".grd -K -Xc -Yc > $outfile
   psxy $area $proj -O -K -Sp ../../baseline_difference/grids/outline.xy \
      >> $outfile
   #psscale -D23.5/5/5/0.5 -B2 -C.utec_r.cpt -O -K >> $outfile
   #psscale -D4/5/5/1 -B5 -C.utec_q.cpt -O -K >> $outfile
   psscale -D23.5/5/-5/0.5 -B2 -C.utec_cleaned.cpt -O -K >> $outfile
   pstext $proj $area -O -N << TEXT >> $outfile
   323900 5598500 10 0 0 1 Depth (m)
TEXT
   echo "done."
}


formats(){
   echo -n "convert to pdf "
   ps2pdf -dOptimize=true -sPAPERSIZE=a4 $outfile \
      ./images/`basename $outfile .ps`.pdf
   echo -n "and jpeg... "
   gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE \
      "-sOutputFile=./images/`basename $outfile .ps`.jpg" \
      "$outfile" > /dev/null
   echo "done."
}

# which dataset would you like to process today, sir?
#roll           # roll calibrated data
#qloud          # qloud output
cleaned         # cleaned bathy
#hastings       # hastings tidal correction output

name=$(basename $input .txt)

bm              # blockmean the data
mksurf          # make surfaces (interpolated)
mkgrad          # make gradient maps
mkmask          # make masks
clip            # clip the surfaces with the masks
plot            # plot the final bathy
formats         # convert the output

exit 0
