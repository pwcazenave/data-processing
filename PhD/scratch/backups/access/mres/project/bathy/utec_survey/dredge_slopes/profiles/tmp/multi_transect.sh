#!/bin/bash

# script to take transects across the surfaced bathy

pro_area=-R0/1200/-28/-19
pro_proj=-JX14/5
g_area=-R580000/583500/95000/97500
g_proj=-Jx0.003
h_area=-R0/45/0/20
h_proj=-JX14/4
gridfile=../raw_bathy_final.grd

gmtset D_FORMAT %6.2f

# make sure the raw_data directory exists
if [ ! -d ./raw_data ]; then
   mkdir ./raw_data/
fi

# make the transect lines using project
echo -n "make the profile tracks: "
echo -n "1 "
project -C581550/95550 -E580900/96550 -G0.25 -N > ./raw_data/profile1.trk
echo -n "2 "
project -C581750/95650 -E581100/96650 -G0.25 -N > ./raw_data/profile2.trk
echo -n "3 "
project -C581950/95750 -E581300/96750 -G0.25 -N > ./raw_data/profile3.trk
echo -n "4 "
project -C582150/95850 -E581500/96850 -G0.25 -N > ./raw_data/profile4.trk
echo -n "5 "
project -C582350/95950 -E581700/96950 -G0.25 -N > ./raw_data/profile5.trk
echo -n "6 "
project -C582550/96050 -E581900/97050 -G0.25 -N > ./raw_data/profile6.trk
echo "done."

# do a for loop to go take the data points from the grid file
for transect in ./raw_data/*.trk; do
   echo -n "profiling $gridfile with $transect... "
   grdtrack "$transect" -G"$gridfile" -S > \
      ./raw_data/$(basename $transect .trk).pfl
   echo "done."
done

# compile and run the fortran gradient/slope programs by sourcing them
# as csh scripts as bash didn't like running them...
. ./ifort.list
. ./graadient.run

# check for an image output directory
if [ ! -d ./images/ ]; then
   mkdir ./images/
fi

# plot each of the profiles on a separate postscript image
for profile2 in ./raw_data/*.pfl; do
   echo -n "plotting $profile2... "
   awk '{print $3, $4}' $profile2 | \
      psxy $pro_area $pro_proj -W1/200/0/50 -P -Xc -Y21 -K \
      -Ba200f100g200:"Distance Along Line (m)":/a2f1g2:"Depth (m) CD":WeSn \
      > ./images/$(basename $profile2 .pfl).ps
   # add the grid file and the location of each profile
   grdimage $g_area $g_proj -C../utec.cpt -O -K -X1.6 -Y-10 \
      -Ba1000f500g1000:"Eastings":/a1000f500g1000:"Northings":WeSn \
      -I../grad_resampled_2m.grd ../final_resampled_2m.grd \
      >> ./images/$(basename $profile2 .pfl).ps
   psxy $g_area $g_proj -H1 -W2/0/0/0 -B0 -O -K $profile2 \
      >> ./images/$(basename $profile2 .pfl).ps
   echo "done."
done

# add in the associated histogram
for slope in ./raw_data/*.xy; do
   echo -n "calculating the histogram... "
   awk '{if ($1<1 && $1>-1) print sqrt($1^2), sqrt($2^2)}' $slope | \
      pshistogram $h_area $h_proj \
      -Ba10f5g10:"Slope Angle (@+o@+)":/a2f1g2:,%:WeSn \
      -G200/0/100 -L1/0/0/0 -T1 -H2 -P -W1 -X-1.45 -Y-7 -Z1 -O \
      >> ./images/$(basename $slope .xy).ps
   echo "done."
done

# convert the images to jpeg and pdf from postscript
for image in ./images/*.ps; do
   echo -n "converting $image to pdf "
   ps2pdf -sPAPERSIZE=a4 "$image" \
      "./images/$(basename "$image" .ps).pdf"
   echo -n "and jpeg... "
   gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE \
      "-sOutputFile=./images/$(basename "$image" .ps).jpg" \
      "$image" > /dev/null
   echo "done."
done

echo "all done."

gmtset D_FORMAT %g

exit 0
