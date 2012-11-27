#! /bin/csh
set outfile=ray_gmt.ps
set area=-R0/200/-30/0

awk '{print $1, $2}' travel_time > question3 

psbasemap -JX15 $area -X2.5 -Y5 -Ba500f50:"Distance(km)":/a100f10:"Depth(km)"::." RAY":nSeW -P -K > $outfile
psxy question3 -JX15 $area -W2/255/0/0 -B -A -V -O >> $outfile


gs -sPAPERSIZE=a4 $outfile
