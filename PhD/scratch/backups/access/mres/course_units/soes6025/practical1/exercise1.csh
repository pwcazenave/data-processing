#! /bin/csh
set outfile=exercise1.ps
set gridfile=/users/soes/smd9/temp/soes6025/etopo5.grd
gmtset HEADER_FONT_SIZE	= 20p
#
# Upper panel (map)
#

psbasemap -JM6 -R-70/0/20/65 -Ba10f5/a10f5:."ETOP05 bathymetry & topography":NSEW -V -P -X1.1 -Y4 -K > $outfile
makecpt -Crelief -T-8000/8000/100 -Z > exercise1.cpt
grdimage $gridfile -JM -R -Cexercise1.cpt -V -O -K >> $outfile
pscoast -JM -R -Di -A0/0/1 -W2/0 -V -O -K >> $outfile
pstext -JM -R -V -G255/0/0 -O -K << END >> $outfile
-57 48.5 14 0 1 6 A
-6 40 14 0 1 6 B
END
more exercise1.a_db|grep '<'|tr '<' ' '|tr '|' ' '|sort -k 1 > exercise1.xy
psxy exercise1.xy -JM -R -W5/255/0/0 -V -O -K >> $outfile
#
# Lower panel (line graph)
#
grdtrack exercise1.xy -G$gridfile -R -V > exercise1.xyg
more exercise1.xyg | awk '{print $1, $3}' > exercise1.xg
psbasemap -JX6/2 -R-55/-8/-6000/1000 -Ba10f5:"Longitude":/a1000f500:"metres":nSeW -V -Y-2.5 -O -K >> $outfile
psxy exercise1.xg -JX -R -W5/255/0/0 -V -O -K >> $outfile
pstext -JX -R -V -G255/0/0 -N -O << END >> $outfile
-55 -7500 24 0 1 6 A
-8 -7500 24 0 1 6 B
END

#
# Display the results
#
gs -sPAPERSIZE=a4 $outfile
