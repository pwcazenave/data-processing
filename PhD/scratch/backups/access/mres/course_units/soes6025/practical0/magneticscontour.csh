#! /bin/csh -f
#
# grid GMT script
#
set area = -R-60/100/-0/100
set proj = -Jx0.1
set outfile = magneticscontour.ps
psbasemap $area $proj -B30 -P -K >! $outfile
grdcontour $area $proj -C5000 magnetics.grd -O >> $outfile
