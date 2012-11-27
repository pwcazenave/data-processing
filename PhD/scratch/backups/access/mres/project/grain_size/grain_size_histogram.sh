#! /bin/csh

# plot a histogram of the grain size distribution

set area=-R0/6/0/10
set proj=-JX15
set outfile=histogram.ps

# get the grain size data from the raw data file and pipe it into pshistogram
awk '{print $3}' data.txt | pshistogram $area $proj -Ba0.5f0.25:"Grain Size (cm)":/a1f0.5:%::."Grain Size Distribution at Hastings Shingle Bank":WeSn -W0.01 -G100/100/100 -L0/50/200 -T0 -Z1 -K -P -Xc -Yc > $outfile

# add some text
pstext -O $area $proj << TEXT >> $outfile
4 9.5 12 0 1 1 Number of Samples: 74
TEXT

# view the image
gs $outfile
