#!/bin/bash

# script to pull the wave data from the header

for i in *lst; do 
   sed -n '/\ \ Cycle/,$p' $i | \
      awk '
      BEGIN{
         OFS=","
      }
      {
         print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14
      }' | \
      sed 's/AZDRZZ01:1/SampleDuration/g;s/DEPHPM01:1/InstrumentDepth/g;s/GMNLMB01:1/MinWaveHeight/g;s/GMXLMB01:1/MaxWaveHeight/g;s/GTCAMB01:1/MeanPeriod/g;s/GTDHMB01:1/SignificantWaveHeight/g;s/GTKCMB01:1/MinWaveHeight2/g;s/GTKDMB01:1/MaxWaveHeight2/g;s/GTZAMB01:1/MeanZeroCrossing/g;s/GMXAMB01:1/MaxMinWaveLevelSum/g;s/GMXBMB01:1/MaxMinWaveLevelSum2/g' | \
      grep -Ev "[0-9]P" > ${i%.lst}.csv
done
