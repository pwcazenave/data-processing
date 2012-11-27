#! /bin/csh -f
#
# first GMT script
#
set area = -R-11/3/49/60
set proj = -Jm1:1e7
set outfile = first.ps

psbasemap $area $proj -B1 -P -K >! $outfile
pscoast $area $proj -O -Df -G30/200/10 -W1 -K >> $outfile
psxy $area $proj -O -Ss0.3 -G255/0/0 soton.dat >> $outfile
