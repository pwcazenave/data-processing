#! /bin/csh

# plot a histogram of the depths to see where the rubbish values extend to:

set area=-R-49/-40/0/25000
set proj=-JX15
set outfile=./images/histogram.ps

pshistogram $area $proj -B1/5000:."Histogram of Depth distribution":WeSn -W0.001 -T2 -Z0 -K -P -Xc -Yc -G0/150/50 ./raw_data/bathy.xyz > $outfile

# display the image
gs -sPAPERSIZE=a4 $outfile
