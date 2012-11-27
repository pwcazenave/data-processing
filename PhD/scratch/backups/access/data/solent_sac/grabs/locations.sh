#! /bin/csh

# map to check the conversion I did in excel (!) of the lat (N) and long (E) DM.m to lat (N) and long (E) D.d was working as I couldn't get it to work in arcmap.

set outfile=grab_locations.ps
set area=-R358.4/359.2/50.6/50.9
set proj=-JM20

pscoast $area $proj -Xc -Yc -B0.1/0.05:."Grab Locations": -K -Df -V -S0/70/180 -G0/160/70 -W0/0/0 > $outfile

psxy $area $proj -O -Sx0.1 -W1/200/50/50 grabs_2_columns.txt >> $outfile

gs $outfile

