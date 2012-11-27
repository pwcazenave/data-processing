#! /bin/csh
set outfile=exercise2.ps
set gridfile1=/users/soes/smd9/temp/soes6025/etopo5.grd
set gridfile2=/users/soes/smd9/temp/soes6025/topo_7.2.grd
#
# Upper left panel
#

psbasemap -JM3 -R-18/-16/32/33.5 -Ba1f1/a1f1:."ETOP05":NSEW -V -P -X0.8 -Y7 -K > $outfile
makecpt -Crelief -T-10376/7833/100 -Z > exercise2a.cpt
grdimage $gridfile1 -JM -R -Cexercise2a.cpt -V -O -K >> $outfile

#
# Upper right panel
#

psbasemap -JM -R -Ba1f1/a1f1:."Sandwell & Smith":NSEw -V -P -X3.6 -Y0 -O -K >> $outfile
makecpt -Crelief -T-1078.97/818.333/100 -Z > exercise2b.cpt
grdimage $gridfile2 -JM -R -Cexercise2b.cpt -V -O -K >> $outfile
#
# Lower left panel
#

psbasemap -JM -R -Ba1f1/a1f1:."":NSEW -V -P -X-3.6 -Y-5.5 -O -K >> $outfile
grdcut $gridfile2 -Gtopo_7.2_cut.grd -R -V
grdsample topo_7.2_cut.grd -Gtopo_7.2_cut_resampled.grd -I0.0833333 -V
grdimage topo_7.2_cut_resampled.grd -JM -R -Cexercise2b.cpt -V -O -K >> $outfile

#
# Lower right panel
#

psbasemap -JM -R -Ba1f1/a1f1:."":NSEw -V -P -X3.6 -Y0 -O -K >> $outfile
grdcut $gridfile1 -Getopo5_cut.grd -R -V
grdmath -R -V topo_7.2_cut_resampled.grd 10 DIV etopo5_cut.grd SUB = gridmath.grd
makecpt -Crelief -T-384.407/4492.07/100 -Z > exercise2c.cpt
grdimage gridmath.grd -JM -R -Cexercise2c.cpt -V -O >> $outfile

#
# Display the results
#
gs -sPAPERSIZE=a4 $outfile
