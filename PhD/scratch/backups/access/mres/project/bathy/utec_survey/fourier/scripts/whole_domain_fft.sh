#!/bin/bash

# script to plot the results of the 2-D fourier transform over the entire bank

#set -x

area=-R578106/588291/91505/98686
proj=0.0022
samp_size=250

echo $samp_size

# things to sample:
# 3. dir 4. dir err 5. wl 6. wl err 7. amp 8. amp err
col1=3
col2=5
col3=4

# how many are we doing?
total=3

# get the naming right
#       0     1     2   3     4     5
#       3     4     5   6     7     8
names=(dir dir_err wl wl_err amp amp_err)
samp1=${names[$(($col1-3))]} # everything starts from 0
samp2=${names[$(($col2-3))]}
samp3=${names[$(($col3-3))]}

min_thresh1=140 # threshold minimum of col1 variable (dir)
max_thresh1=170 # threshold maximum 
min_thresh2=10 # threshold minimum of col2 variable (wl)
max_thresh2=25 # threshold maximum 
min_thresh3=0 # threshold minimum of col3 variable (dir_err)
max_thresh3=180 # threshold maximum 

pref=entire_domain_results
cpt=./cpts/hsb.cpt
infile=./raw_data/matlab_results/entire_domain/${pref}_${samp_size}.txt
suffix1=_${samp1}=${min_thresh1}-${max_thresh1}
suffix2=_${samp2}=${min_thresh2}-${max_thresh2}
suffix3=_${samp3}=${min_thresh3}-${max_thresh3}
if [ $total -eq 1 ]; then
   outfile=./images/${pref}_${samp_size}_fft${suffix1}.ps
elif [ $total -eq 2 ]; then
   outfile=./images/${pref}_${samp_size}_fft${suffix1}${suffix2}.ps
else
   outfile=./images/${pref}_${samp_size}_fft${suffix1}${suffix2}${suffix3}.ps
fi

dos2unix $infile &> /dev/null

negfilter1(){
   awk '{if ($3!="NaN" && $'$1'>'$2' && $'$1'<'$3')
      print $1,$2,$3-$4,$5*('${proj}'*20)}' $infile
}
negfilter2(){
   awk '{if ($3!="NaN" && $'$1'>'$2' && $'$1'<'$3' && $'$4'>'$5' && $'$4'<'$6')
      print $1,$2,$3-$4,$5*('${proj}'*20)}' $infile
}
negfilter3(){
   awk '{if ($3!="NaN" && $'$1'>'$2' && $'$1'<'$3' && $'$4'>'$5' && $'$4'<'$6' && $'$7'>'$8' && $'$7'<'$9')
      print $1,$2,$3-$4,$5*('${proj}'*20)}' $infile
}
posfilter1(){
   awk '{if ($3!="NaN" && $'$1'>'$2' && $'$1'<'$3')
      print $1,$2,$3+$4,$5*('${proj}'*20)}' $infile
}
posfilter2(){
   awk '{if ($3!="NaN" && $'$1'>'$2' && $'$1'<'$3' && $'$4'>'$5' && $'$4'<'$6')
      print $1,$2,$3+$4,$5*('${proj}'*20)}' $infile
}
posfilter3(){
   awk '{if ($3!="NaN" && $'$1'>'$2' && $'$1'<'$3' && $'$4'>'$5' && $'$4'<'$6' && $'$7'>'$8' && $'$7'<'$9')
      print $1,$2,$3+$4,$5*('${proj}'*20)}' $infile
}
filter1(){
   awk '{if ($3!="NaN" && $'$1'>'$2' && $'$1'<'$3')
      print $1,$2,$3,$5*('${proj}'*20)}' $infile
}
filter2(){
   awk '{if ($3!="NaN" && $'$1'>'$2' && $'$1'<'$3' && $'$4'>'$5' && $'$4'<'$6')
      print $1,$2,$3,$5*('${proj}'*20)}' $infile
}
filter3(){
   awk '{if ($3!="NaN" && $'$1'>'$2' && $'$1'<'$3' && $'$4'>'$5' && $'$4'<'$6' && $'$7'>'$8' && $'$7'<'$9')
      print $1,$2,$3,$5*('${proj}'*20)}' $infile
}

formats(){
   echo -n "converting to pdf "
   ps2pdf -sPAPERSIZE=a4 -dPDFSETTINGS=/prepress -q $1 \
      ${1%.ps}.pdf
   echo -n "and jpeg... "
   gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q \
      -sOutputFile=${1%.ps}.jpg $1
   echo "done."
}

mkplot(){
   # add in the bathy
   grdimage $area -Jx${proj} ./grids/all_lines_blockmedian_1m.grd -Xc -Yc -K \
      -Ba2000f200g1000:"Eastings":/a1000f200g1000:"Northings":WeSn \
      -I./grids/all_lines_blockmedian_1m_grad.grd -C./cpts/hsb.cpt \
      > $outfile
   psscale -D10/-3/-7/0.5h -Ba10f2:"Depth (m)": -C./cpts/hsb.cpt -O -K \
      >> $outfile

   # add in all the sample locations as black dots
   awk '{if ($3 != "NaN") print $1,$2}' $infile | \
   psxy $area -Jx$proj -SVT0.1/0.05/0.05n0.5 -O -K -G0/0/0 -Sc0.07\
      >> $outfile

   # +ve err
   posfilter${total} \
      $col1 $min_thresh1 $max_thresh1 \
      $col2 $min_thresh2 $max_thresh2 \
      $col3 $min_thresh3 $max_thresh3 | \
      psxy $area -Jx$proj -SVT0.1/0.05/0.05n0.5 -O -K -G255/255/255 \
      >> $outfile
   # -ve err
   negfilter${total} \
      $col1 $min_thresh1 $max_thresh1 \
      $col2 $min_thresh2 $max_thresh2 \
      $col3 $min_thresh3 $max_thresh3 | \
      psxy $area -Jx$proj -SVT0.1/0.05/0.05n0.5 -O -K -G255/255/255 \
      >> $outfile
   # vector
   filter${total} \
      $col1 $min_thresh1 $max_thresh1 \
      $col2 $min_thresh2 $max_thresh2 \
      $col3 $min_thresh3 $max_thresh3 | \
      psxy $area -Jx$proj -SVT0.15/0.0525/0.0525n0.5 -O -K -G0/0/0 \
      >> $outfile
   # add in a key
   length=$(echo "scale=5; 10*($proj*20)" | bc -l)
   psxy $area -Jx$proj -SVT0.3/0.15/0.15n0.5 -O -K -G0/0/0 << KEY >> $outfile
   586200 92400 90 $length
KEY
   pstext $area -Jx$proj -O -D0.7/-0.12 -W255/255/255O255/255/255 \
      << TEXT >> $outfile
      586200 92400 10 0 0 1 10m wavelength
TEXT
   formats $outfile
   \rm -f $outfile

}

mkplot

exit 0
