#! /bin/csh -f
#
# grid GMT script
#
set area = -R-60/100/-0/100
set proj = -Jx0.1
set outfile = magneticscontourpaltrack.ps
psbasemap $area $proj -B30 -P -K >! $outfile
grdimage $area $proj -Cmagnetics.cpt magnetics.grd -O -K >> $outfile
grdcontour $area $proj -C5000 magnetics.grd -O -K >> $outfile
awk '{print $1, $2}' grdout.dat | psxy $area $proj -O -Ss0.05 -G255/0/0 >> $outfile
