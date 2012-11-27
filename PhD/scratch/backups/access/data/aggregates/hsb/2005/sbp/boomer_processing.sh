#!/bin/bash

# process the hastings boomer data as best as possible.

which suximage &>/dev/null || echo "Please set up the geophys package."

for file in ./raw_data/*.sgy; do
   echo "working on $file... "
   segyread tape=$file endian=0 verbose=0| \
      segyclean verbose=0 \
      > ./raw_data/su/$(basename $file .sgy).su
   echo "done."
#      supef maxing=0.0001 | \
#      sufilter amps=0,1,1,0 f=50,500,1500,3000 \
done
\rm -f ./binary ./header

# view each and every output file
#for sufile in ./raw_data/cleaned/*.su; do
for sufile in ./raw_data/su/*.su; do
   echo -n "plotting $sufile... "
   psimage n1=2560 perc=99 verbose=0 style=normal legend=1 units=s < $sufile \
      > ./images/$(basename $sufile .su).ps
   echo "done."
done

# Read the raw SEG-Y files and write back out as su files
#segyread tape=boomer.sgy endian=0 | segyclean > boomer.su
# View the output using this
#suximage < boomer.su perc=98

# The data looks pretty noisy, so lets try bandpass filtering
#segyread tape=boomer.sgy endian=0 trmin=1 trmax=1 | segyclean | \
#  sufilter amps=1.0,1.0,1.0,1.0 f=50,300,3000,6000 | \
#  sufft | suamp mode=amp | suxwigb style=vsp

# When you're happy with the corner points, try applying it to
# the real data
#sufilter < boomer.su amps=0.0,1.0,1.0,0.0 f=50,300,3000,6000 > boomer.filt.su
#suximage < boomer.filt.su perc=98

# We want to have a go at migrating the data, to do this we need to add cdps numbers
#sushw < boomer.filt.su key=cdp a=1 b=1 > boomer.cdp.su
# and now we can use a simple F-K stolt migration
#sustolt < boomer.cdp.su \
#  cdpmin=1 cdpmax=2600 dxcdp=1.0 \
#  fmax=5000 tmig=0.0,0.15 \
#  vmig=1500,1600 verbose=1 > boomer.mig.su
#suximage < boomer.mig.su perc=99

