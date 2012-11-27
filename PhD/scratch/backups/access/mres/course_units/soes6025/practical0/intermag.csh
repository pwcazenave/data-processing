#! /bin/csh -f
#
# grid GMT script
#
set area = -R0/49/41000/61000
set proj = -Jx0.2/0.001
set outfile = intermag.ps
psbasemap $area $proj -B30/300 -P -K >! $outfile
awk '{print $3, $4}' grdout.dat |\
psxy $area $proj -O -Ss0.3 -G255/0/0 >> $outfile
