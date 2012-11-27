#! /bin/csh

# script to (quickly?) plot the english channel and the survey location

set area_uk=-R-11/3/48/59.5
set proj_uk=-JM4
set area_hastings=-R-1.5/2.5/50/52
set proj_hastings=-Jm5
set outfile=channel.ps

#gmtset OUTPUT_DEGREE_FORMAT +D

# add a basemap (hastings)
psbasemap $area_hastings $proj_hastings -K -Ba0.5f0.25 > $outfile

# add the local coastline (hastings)
pscoast $area_hastings $proj_hastings -W0/0/0 -Df -O -K >> $outfile

# add the survey location

awk '{print $8, $4}' coords.dat | psxy $area_hastings $proj_hastings -O -K -Sc1 -V >> $outfile

# make the basemap (uk)

gmtset BASEMAP_TYPE plain

psbasemap $area_uk $proj_uk -O -K -B0 -X0.02 -Y10.239 >> $outfile

# add the coastline (uk)
pscoast $area_uk $proj_uk -W0/0/0 -Di -G255/255/255 -S255/255/255 -O -K >> $outfile

# add the general location to the uk map
psxy $area_uk $proj_uk -O -K -W255/0/0 -V << HASTINGS >> $outfile
-1.5 50
2.5 50
2.5 52
-1.5 52
-1.5 50
HASTINGS

gmtset BASEMAP_TYPE fancy

# view the image
kghostview $outfile
