#!/bin/bash

# script to plot histograms and roses of the fft results for orientation 
# and wavelength

dir_area=-R0/180/0/20
wav_area=-R0/30/0/30
proj=-JX10

samples=(35 70 110 150) # 185)

formats(){
   echo -n "converting to pdf "
   ps2pdf -sPAPERSIZE=a4 -dPDFSETTINGS=/prepress -q $1 \
      ${1%.ps}.pdf
   echo -n "and jpeg... "
   gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q \
      -sOutputFile=${1%.ps}.jpg $1
   echo "done."
}

for ((iter=0; iter<5; iter++)); do
   for ((curr=0; curr<${#samples[@]}; curr++)); do
      zone=$(($iter+1))
      sampl=${samples[curr]}
      cutoff=15
      gres=1

      pref=zone${zone}_${sampl}m_${gres}m_${cutoff}m_cutoff

      infile=./raw_data/matlab_results/${pref}.txt
      outfile=./images/stats_subsets/${pref}_histograms_rose.ps

      echo -n "working on ${pref}.txt: direction... "

      grep -v NaN $infile | awk '{if ($3<90) print $5,$3+90; else print $5,$3-90}' | \
      #grep -v NaN $infile | awk '{print $5,$3+90}' | \
         pshistogram $dir_area -Z1 -T1 -JX10c -W1 -G128/128/128 -L1 -K \
         -Ba90f45g90:"Orientation (@+o@+)":/a5f1g5:,-%:WeSn \
         > $outfile
      echo -n "wavelength... "
      grep -v NaN $infile | awk '{if ($3<90) print $5,$3+90; else print $5,$3-90}' | \
      #grep -v NaN $infile | awk '{print $5,$3+90}' | \
         pshistogram $wav_area -Z1 -T0 -JX10c -W0.5 -G128/128/128 -L1 -O -X13 \
         -Ba5f1g5:"Wavelength (m)":/a5f1g5:,-%:WeSn \
         >> $outfile
      echo "done."

      formats $outfile
   done
done

         
