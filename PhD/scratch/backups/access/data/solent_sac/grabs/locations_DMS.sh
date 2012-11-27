#! /bin/csh

# map to check the conversion I did in excel (!) of the lat (N) and long (E) DM.m to lat (N) and long (E) D.d was working as I couldn't get it to work in arcmap.

set outfile=grab_locations.ps
set area=-R358.4/359.2/50.6/50.9
set sss_area=-R-1.69971/-0.799707/50.5498/50.9798
set proj=-JM20

gmtset OUTPUT_DEGREE_FORMAT ddd:mm:ss

pscoast $area $proj -Xc -Yc -B0.1/0.05:."Grab Locations": -K -Df -V -S0/70/180 -G0/160/70 -W0/0/0 > $outfile

#gmtset OUTPUT_DEGREE_FORMAT +D
#xyz2grd satellite.dat -I0.25 $sss_area -Goverall.grd
#grdimage overall.grd $sss_area $proj -Csidescan.cpt -O -K -S0 >> $outfile

psxy $area $proj -O -Sx0.1 -W1/200/50/50 grabs_DMS.txt >> $outfile

gs $outfile

