#! /bin/csh
set outfile=ray_gmt.ps
set area=-R0/200/-30/0

psbasemap -JX15 $area -X2.5 -Y5 -Ba500f50:"Distance(km)":/a100f10:"Depth(km)"::." RAY":nSeW -P -K > $outfile
psxy ray_coords -JX10 $area -W16/255/0/0 -B -A -V -O >> $outfile


gs -sPAPERSIZE=a4 $outfile
