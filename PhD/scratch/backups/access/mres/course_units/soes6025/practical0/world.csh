#! /bin/csh -f
#
# first GMT script
#
set area = -R0/360/-70/70
set proj = -Jm1:2.2e8
set outfile = world.ps

psbasemap $area $proj -B30 -P -K >! $outfile
pscoast $area $proj -O -Dl -G30/200/10 -S0/50/230 -W1 -K >> $outfile
psxy $area $proj -O -Sc -G255/0/0 quakes.dat >> $outfile
