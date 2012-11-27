#!/bin/bash
#
#  Pierre Cazenave 20/07/07; updated 06/03/08, 11/03/08, 12/03/08
#
#  Script to take transects across the surfaced bathy. Some things are
#+ automated, some are not. I'm still tweaking this to try and get it completely
#+ input free, but it's a tough one...
#

pro_proj=-JX14/5
g_area=-R578106/588291/91503/98688
#g_area=-R583000/585000/93500/95500
#g_proj=-Jx0.005
g_proj=-Jx0.0009
h_area=-R0/45/0/40
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
   echo -n "make the profile tracks: "
   echo -n "1 "
   project -C583400/94590 -E584000/95000 -G0.5 -N > ./raw_data/dunes1.trk
   echo -n "2 "
   project -C583200/93900 -E584350/94700 -G0.5 -N > ./raw_data/dunes2.trk
   echo -n "3 "
   project -C587000/97450 -E587600/98000 -G0.5 -N > ./raw_data/dunes3.trk
   echo -n "4 "
   project -C586100/96100 -E586900/97000 -G0.5 -N > ./raw_data/dunes4.trk
   echo -n "5 "
   project -C585300/95500 -E586000/95950 -G0.5 -N > ./raw_data/dunes5.trk
   echo -n "6 "
   project -C583400/94390 -E584000/94800 -G0.5 -N > ./raw_data/dunes6.trk

   # add in the transects to pick up the noise between swaths
   echo -n "7 "
   project -C585000/96000 -E584000/98000 -G0.5 -N > ./raw_data/dunes7.trk
   echo -n "8 "
   project -C582100/96900 -E581600/98000 -G0.5 -N > ./raw_data/dunes8.trk
   echo -n "9 "
   project -C580000/92000 -E579000/94000 -G0.5 -N > ./raw_data/dunes9.trk
   echo -n "10 "
   project -C580500/92000 -E579500/94000 -G0.5 -N > ./raw_data/dunes10.trk
   echo -n "11 "
   project -C587000/94500 -E586000/96000 -G0.5 -N > ./raw_data/dunes11.trk
   echo -n "12 "
   project -C588000/96000 -E587300/97750 -G0.5 -N > ./raw_data/dunes12.trk
   echo "done."
}

sample_grid()
{
   # do a for loop to go take the data points from the grid file
   for transect in ./raw_data/dunes*.trk; do
      echo -n "profiling $gridfile with $transect... "
      grdtrack "$transect" -G"$gridfile" -S > \
         ${transect%.trk}.pfl
      echo "done."
   done
}

run_fort()
{
   # find the number of files that need processing
   files=$(ls ./raw_data/dunes*.pfl | wc -l)

   # run the fortran gradient/slope programs using the expect script
   echo -n "run and/or compile the fortran codes... "
   if [ ! -f ./gradient ]; then
      echo -n "compiling... "
      ifort -o ./gradient ./slope.f90 -traceback
      echo -n "running... "
      ./run_fortran.exp $files dunes
      echo "done."
   else 
      echo "running... "
      ./run_fortran.exp $files dunes
      echo "done."
   fi
}

# check for an image output directory
if [ ! -d ./images/ ]; then
   mkdir ./images/
fi

# plot each of the profiles on a separate postscript image
makecpt -Cwysiwyg -T-51/-14/1 -Z > .3d.cpt

# remove the two decimal places
gmtset D_FORMAT %6.0f

plot_profile()
{
   for profile2 in ./raw_data/dunes?.pfl ./raw_data/dunes??.pfl; do
      echo -n "plotting $profile2... "
      mm_area=$(awk '{print $3, $4}' $profile2 | minmax -I2)
      awk '{print $3, $4}' $profile2 | \
         psxy $mm_area $pro_proj -W5/200/0/50 -P -Xc -Y21 -K \
         -Ba200f100g200:"Distance Along Line (m)":/a2f1g2:"Depth (m) CD":WeSn \
         > ./images/$(basename $profile2 .pfl).ps
      # add the grid file and the location of each profile
      grdimage $g_area $g_proj -C./.3d.cpt -O -K -X2.6 -Y-10 \
         -Ba2000f1000:"Eastings":/a1000f500:"Northings":WeSn \
         -I../bathy/50cm_bathy_grad_resampled_2m.grd \
         ../bathy/50cm_bathy_final_resampled_2m.grd \
         >> ./images/$(basename $profile2 .pfl).ps
      psxy $g_area $g_proj -H1 -W5/0/0/0 -B0 -O -K $profile2 \
         >> ./images/$(basename $profile2 .pfl).ps
      echo "done."
   done
}

plot_hist()
{
   # add in the associated histogram
   for slope in ./raw_data/dunes?.xy ./raw_data/dunes??.xy; do
      echo -n "calculating the histogram... "
      awk '{if ($1<1 && $1>-1) print sqrt($1^2), sqrt($2^2)}' $slope | \
         pshistogram $h_area $h_proj \
         -Ba10f5g10:"Slope Angle (@+o@+)":/a10f5g10:,%:WeSn \
         -G200/0/100 -L1/0/0/0 -T1 -H1 -P -W1.25 -X-2.5 -Y-8 -Z1 -O -K \
         >> ./images/$(basename $slope .xy).ps
      echo "done."
   done
}

plot_qhist()
{
   # add in a cumulative histogram
   for q_slope in ./raw_data/dunes*.xy; do
      echo -n "calculating the cumulative histogram... "
      awk '{if ($1<1 && $1>-1) print sqrt($1^2), sqrt($2^2)}' $q_slope | \
         pshistogram $q_area $q_proj \
         -Ba10f5g10:"Slope Angle (@+o@+)":/a20f10g20:,%:WeSn \
         -G0/200/50 -L1/0/0/0 -T1 -H1 -P -W1.25 -X9.1 -Z1 -O -Q \
         >> ./images/$(basename $q_slope .xy).ps   
      echo "done."
   done
}

formats ()
{
   # convert the images to jpeg and pdf from postscript
   for image in ./images/dunes?.ps ./images/dunes??.ps; do
      echo -n "converting $image to pdf "
      ps2pdf -sPAPERSIZE=a4 "$image" \
         ${image%.ps}.pdf
      echo -n "and jpeg... "
      gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE \
         "-sOutputFile=${image%.ps}.jpg" \
         "$image" > /dev/null
      echo "done."
   done
}

gmtset D_FORMAT %6.2f

#mktrans
#sample_grid
run_fort
plot_profile
plot_hist
plot_qhist
formats

echo "all done."

exit 0
