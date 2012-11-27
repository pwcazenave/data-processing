#!/bin/bash

# script to plot cumulative histograms of the model calibration outputs
gmtset HEADER_FONT_SIZE=12 ANNOT_FONT_SIZE=8 LABEL_FONT_SIZE=8 HEADER_OFFSET=0.1

proj=-JX7/4

gmtAreas=("-R0/40/0/3" "-R0/25/0/50" "-R0/20/-300/300")
stats=(rms std phase)
locations=(offshore_tides coast_tides currents)
titles=("RMS" "Standard Deviation" "Phase")
boxSize=(0.01 0.1 15)
offsetsX=(0 9 9)
offsetsY=(0 6 6)

colours=(navy black green orchid orange red)

# for each of the three data stats
for ((currStat=0; currStat<${#stats[@]}; currStat++)); do

   currInfile=(./text_output/m20-45_${stats[$currStat]}_{offshore_tides,coast_tides,currents}.csv)
#   currOutput=./images/cumulative_${stats[$currStat]}.ps
   currOutput=./images/cumulative.ps

   keyLocsY=(1.4 1.5 1.6 1.7 1.8 1.9)
   keyText=("M=20" "M=25" "M=30" "M=35" "M=40" "M=45")

   # number of iterations
   numIter=$(awk -F, '{if (NR==1) print NF}' $currInfile)

   # initilialise the rms/std/phase figure
   psbasemap ${gmtAreas[$currStat]} $proj -K -B0 > $currOutput

   for ((currType=0; currType<${#currInfile[@]}; currType++)); do
      # add the offshore/coast/current basemaps
      psbasemap ${gmtAreas[$currStat]} $proj -O -K \
      -X$((0+${offsetsX[$currType]})) -Y$((0+${offsetsY[$currStat]})) \
      -B5:"Sample number":/0.2:"Tidal velocity (ms@+-1@+)"::."${titles[$currStat]}":WeSn >> $currOutput

      for currIter in $(seq 0 $((${numIter}-1))); do
         echo "$(($currIter+1)) of $numIter of ${locations[$currStat]} of ${stats[$currStat]}"
         pshistogram ${gmtAreas[$currStat]} $proj ${currInfile[$currStat]} \
         -O -K -T$(($currIter+1)) -W${boxSize[$currType]} -Q -Io -Z1 | \
         psxy -V ${gmtAreas[$currStat]} $proj -W2/${colours[$currIter]} -O -K \
         >> $currOutput
#         cut -f$(($currIter+1)) -d"," ${currInfile[$currStat]} | sort -g > /tmp/valY.tmp
#         seq $(wc -l /tmp/valY.tmp | cut -f1 -d' ') > /tmp/valX.tmp
#         paste /tmp/val{X,Y}.tmp | \
#         psxy ${gmtAreas[$currStat]} $proj -W2/${colours[$currIter]} \
#         -O -K >> $currOutput
#         paste /tmp/val{X,Y}.tmp | \
#         psxy ${gmtAreas[$currStat]} $proj -W2/${colours[$currIter]} \
#         -Sc0.05 -G${colours[$currIter]} -O -K >> $currOutput
         # add a key
#         psxy ${gmtAreas[$currStat]} $proj -W2/${colours[$currIter]} -O -K << KEYLINE >> $currOutput
#         1 ${keyLocsY[$currIter]}
#         2 ${keyLocsY[$currIter]}
#KEYLINE
#         psxy ${gmtAreas[$currStat]} $proj -W2/${colours[$currIter]} -G${colours[$currIter]} \
#         -Sc0.05 -O -K << KEYPOINT >> $currOutput
#         1 ${keyLocsY[$currIter]}
#         2 ${keyLocsY[$currIter]}
#KEYPOINT
#         pstext ${gmtAreas[$currStat]} $proj -G${colours[$currIter]} -O -K << KEYTEXT >> $currOutput
#         3 $(echo "scale=2; ${keyLocsY[$currIter]}-0.02" | bc -l) 7 0 1 1 ${keyText[$currIter]}
#KEYTEXT
         # clean up
#         rm -f /tmp/val{X,Y}.tmp
      done
   done
done
