#!/bin/bash

# script to plot a section of the profile where there are some artefacts from 
# processing.

# generic variables, you know the drill
proj=-JX23/15
gmtset D_FORMAT=%g

# do a massive for loop which asks which file you want to work on, and what the
# start and end points along the line you'd like to profile are.

echo -n "How many files will we be working on today? "
read files
echo -n "What is the first number of the input files? "
read file_start
echo -n "What is the input file prefix? "
read pref

for loop in $(seq $file_start $((($file_start-1)+$files))); do
   infile="$pref""$loop".pfl
   trans_outfile=./images/$(basename $infile .pfl)_"$loop".ps
#   hist_outfile=./images/noise_histogram_"$loop".ps
   sub_outfile=./raw_data/subsets/$(basename $infile .pfl)_subset_"$loop".pfl

   # start and stop of the point at which you'd like to examine the transect 
   # noise
   echo -n "Start the transect for $infile at (m): "
   read lstart
   echo -n "Stop the transect for $infile at (m): "
   read lstop

   # get the appropriate part of the line (between 1000 and 1100 m along line.
   echo -n "snip the input file... "
   awk '{if ($3 >= lstart && $3 <= lstop) print $3, $4}' \
      lstart=$lstart lstop=$lstop $infile \
      > $sub_outfile
   echo "done."

   # run the fortran code on the extracted section for use in the histogram
   #echo -n "run the fortran expect code... "
   #./run_fortran.exp 1 noise_section_profile
   #echo "done."

   # plot the profile section
   echo -n "plot the profile... "
   area=$(minmax -I1 $sub_outfile)
   psxy $area $proj -Xc -Yc \
   -Ba20f10g20:"Distance Along Line (m)":/a0.2f0.1g0.2:"Depth (m)":WeSn \
   $sub_outfile \
   > $trans_outfile
   echo "done."

   # plot a histogram of the output of the fortran code
   #echo -n "plot the histogram... "
   #pshistogram -R0/100/0/40 $proj -Xc -Yc \
   #   -Ba10f5g10:"Slope Angle (@+o@+)":/a10f5g10:,%:WeSn -G0/50/100 -L1/0/0/0 \
   #   -T1 -W1.25 -H2 ./raw_data/subsets/noise_section_profile1.xy \
   #   > $hist_outfile
   #echo "done."

   # convert as per usual
   echo -n "convert the output file to jpeg "
   gs -sDEVICE=jpeg -sPAPERSIZE=a4 -r300 -dBATCH -dNOPAUSE \
      -sOutputFile=./images/$(basename $trans_outfile .ps).jpg \
      $trans_outfile > /dev/null
   #gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE \
   #   -sOutputFile=./images/$(basename $hist_outfile .ps).jpg \
   #   $hist_outfile > /dev/null
   echo -n "and pdf... "
   ps2pdf -sPAPERSIZE=a4 -dPDFSETTINGS=/screen $trans_outfile \
      ./images/$(basename $trans_outfile .ps).pdf
   #ps2pdf -sPAPERSIZE=a4 -dPDFSETTINGS=/screen $hist_outfile \
   #   ./images/$(basename $hist_outfile .ps).pdf
   echo "done."

done

echo "all done."

exit 0
