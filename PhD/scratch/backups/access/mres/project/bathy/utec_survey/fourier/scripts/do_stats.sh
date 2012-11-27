#!/bin/bash

# script to calculate the stats on the results for each domain, and output
# to a single file

# columns are:
# 1. easting
# 2. northing
# 3. direction
# 4. std dev dir
# 5. wavelength
# 6. std dev wavelength
# 7. amplitude
# 8. std dev amp
aspect=(easting northing dir std_dir wavelength std_wavelength amplitude std_amp)

all_sizes=(35 70 110 150 185)

for ((i=0; i<${#all_sizes[@]}; i++)); do

   analyse=4
   size=${all_sizes[i]}m

   outfile=./stats/2d_fourier_stats_${size}_${aspect[$(($analyse-1))]}.txt
   infiles=($(ls ./raw_data/matlab_results/*$size*cutoff.txt))

   if [ -e $outfile ]; then 
      rm -f $outfile
   fi
   touch $outfile

   for ((file=0; file<${#infiles[@]}; file++)); do
      echo "Direction stats for ${infiles[file]##*/}" >> $outfile
      # get stats on orientation (3)
   #   awk '{if ($1<579600 && $2<97625 || $2>97200 && $2<97625) print $'$analyse'}' ${infiles[file]} | \
      cut -f$analyse ${infiles[file]} | \
         grep -v NaN | stat_moments.awk 2>/dev/null >> $outfile \
         || echo "Error: Too few input values to calculate stats." >> $outfile
      echo "---------------------" >> $outfile
      echo "" >> $outfile
#      echo $file
   done
done
exit 0
