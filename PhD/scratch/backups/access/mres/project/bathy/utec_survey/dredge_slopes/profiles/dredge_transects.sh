#!/bin/bash
#
#  Pierre Cazenave 20/07/07; updated 06/03/08, 11/03/08, 12/03/08
#
#  Script to take transects across the surfaced bathy. Some things are
#+ automated, some are not. I'm still tweaking this to try and get it completely
#+ input free, but it's a tough one...
#

pro_proj=-JX14/5
g_area=-R580000/583500/95000/97500
g_proj=-Jx0.003
h_area=-R0/35/0/35
h_proj=-JX7/5
q_area=-R0/35/0/100
q_proj=-JX7/5
gridfile=../bathy/50cm_bathy_surface.grd

gmtset D_FORMAT %6.2f

# make sure the raw_data directory exists
if [ ! -d ./raw_data ]; then
   mkdir ./raw_data/
fi

mktrans()
{
   # make the transect lines using project
   gmtset D_FORMAT %6.2f
   echo -n "make the profile tracks: "
   echo -n "1 "
   project -C581550/95550 -E580900/96550 -G0.5 -N > ./raw_data/profile1.trk
   echo -n "2 "
   project -C581750/95650 -E581100/96650 -G0.5 -N > ./raw_data/profile2.trk
   echo -n "3 "
   project -C581950/95750 -E581300/96750 -G0.5 -N > ./raw_data/profile3.trk
   echo -n "4 "
   project -C582150/95850 -E581500/96850 -G0.5 -N > ./raw_data/profile4.trk
   echo -n "5 "
   project -C582350/95950 -E581700/96950 -G0.5 -N > ./raw_data/profile5.trk
   echo -n "6 "
   project -C582550/96050 -E581900/97050 -G0.5 -N > ./raw_data/profile6.trk
   echo -n "7 "
   project -C582250/95450 -E581600/96450 -G0.5 -N > ./raw_data/profile7.trk
   echo "done."
   gmtset D_FORMAT %6.2f
    
}

sample_grid()
{
   # do a for loop to go take the data points from the grid file
   for transect in ./raw_data/profile?.trk; do
      echo -n "profiling $gridfile with $transect... "
      grdtrack "$transect" -G"$gridfile" -S > \
         ./raw_data/$(basename $transect .trk).pfl
      echo "done."
      gmtset D_FORMAT %g
   done
}

run_fort()
{
   # find the number of files that need processing
   files=$(ls ./raw_data/profile?.pfl | wc -l)

   # run the fortran gradient/slope programs using the expect script
   echo -n "run and/or compile the fortran codes... "
   if [ ! -f ./gradient ]; then
      echo -n "compiling... "
      ifort -o ./gradient ./slope.f90 -traceback
      echo -n "running... "
      ./run_fortran.exp $files profile
      echo "done."
   else 
      echo "running... "
      ./run_fortran.exp $files profile
      echo "done."
   fi
}

# check for an image output directory
if [ ! -d ./images/ ]; then
   mkdir ./images/
fi

# remove the two decimal places
gmtset D_FORMAT %6.0f

plot_profile()
{
   # plot each of the profiles on a separate postscript image
   for profile2 in ./raw_data/profile?.pfl; do
      echo -n "plotting $profile2... "
      mm_area=$(awk '{print $3, $4}' $profile2 | minmax -I2)
      awk '{print $3, $4}' $profile2 | \
         psxy $mm_area $pro_proj -W5/0/50/200 -P -Xc -Y21 -K \
         -Ba200f100g200:"Distance Along Line (m)":/a2f1g2:"Depth (m) CD":WeSn \
         > ./images/$(basename $profile2 .pfl).ps
   # add the grid file and the location of each profile
         grdimage $g_area $g_proj -C../bathy/utec.cpt -O -K -X1.6 -Y-10 \
            -Ba1000f500:"Eastings":/a1000f500:"Northings":WeSn \
            -I../bathy/dredge_grad_resampled_1m.grd ../bathy/dredge_final_resampled_1m.grd \
            >> ./images/$(basename $profile2 .pfl).ps
            psxy $g_area $g_proj -H1 -W5/0/0/0 -B0 -O -K $profile2 \
         >> ./images/$(basename $profile2 .pfl).ps
      echo "done."
   done
}

plot_hist()
{
   # add in the associated histogram
   for slope in ./raw_data/profile?.xy; do
      echo -n "calculating the histogram... "
      awk '{if ($1<1 && $1>-1) print sqrt($1^2), sqrt($2^2)}' $slope | \
         pshistogram $h_area $h_proj \
         -Ba10f5g10:"Slope Angle (@+o@+)":/a10f5g10:,%:WeSn \
         -G200/0/50 -L1/0/0/0 -T1 -H1 -P -W1.25 -X-2.5 -Y-8 -Z1 -O -K \
         >> ./images/$(basename $slope .xy).ps
      echo "done."
   done
}

plot_qhist()
{
   # add in a cumulative histogram
   for q_slope in ./raw_data/profile?.xy; do
      echo -n "calculating the cumulative histogram... "
      awk '{if ($1<1 && $1>-1) print sqrt($1^2), sqrt($2^2)}' $q_slope | \
         pshistogram $q_area $q_proj \
         -Ba10f5g10:"Slope Angle (@+o@+)":/a20f10g20:,%:WeSn \
         -G0/200/50 -L1/0/0/0 -T1 -H1 -P -W1.25 -X9.1 -Z1 -O -Q \
         >> ./images/$(basename $q_slope .xy).ps
      echo "done."
   done
}

formats()
{
   # convert the images to jpeg and pdf from postscript
   for image in ./images/profile?.ps; do
      echo -n "converting $image to pdf "
      ps2pdf -sPAPERSIZE=a4 "$image" \
         "./images/$(basename "$image" .ps).pdf"
      echo -n "and jpeg... "
      gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE \
         "-sOutputFile=./images/$(basename "$image" .ps).jpg" \
         "$image" > /dev/null
      echo "done."
   done
}

mktrans
sample_grid
run_fort
plot_profile
plot_hist
plot_qhist
formats

echo "all done."

gmtset D_FORMAT %6.2f

exit 0
