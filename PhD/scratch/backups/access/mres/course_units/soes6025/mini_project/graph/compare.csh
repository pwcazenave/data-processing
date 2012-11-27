# /bin/csh

# plot malinverno's (1991) data with my data for Newfoundland to compare the results

gmtset ANNOT_FONT_SIZE = 14p
gmtset HEADER_FONT_SIZE = 20p
gmtset LABEL_FONT_SIZE = 12p

# create a basemap for the graph
psbasemap -R0/150/0/600 -JX12c -B20/100WS -P -K -Xc -Y4.8 >! compare.ps
psbasemap -R -JX -Ba0f0/a0f0:."Spreading Rate vs. Root-mean-square Roughness":wesn -O -K >> compare.ps

# use psxy to plot malinverno's data
psxy -R -JX malin.dat -Ey -O -K -P -Sc0.08 -G255/0/0 -W255/0/0 >> compare.ps

# plot my data on the graph
psxy -H1 -R -JX -Ba20f10:"Full-spreading Rate (mm yr@+-1@+)":/a100f50:"Root-mean-square Roughness (m)":WS ../lines/line107/line107coords.xy -O -K -P -W30/225/0 -Sc0.1 >> compare.ps
psxy -H1 -R -JX ../lines/line109/line109coords.xy -O -K -P -W30/225/0 -Sc0.1 >> compare.ps
psxy -H1 -R -JX ../lines/line2/line2coords.xy -O -K -P -W30/225/0 -Sc0.1 >> compare.ps
psxy -H1 -R -JX ../lines/line201/line201coords.xy -O -K -P -W30/235/0 -Sc0.1 >> compare.ps

# add my mean value with error bars
#psxy -R -JX mymean.dat -Ey -O -K -P -Sx0.08 -G200/50/50 -W200/50/50 >> compare.ps

# plot goff (1991 and 1992) data
psxy -M -Ey -R -JX goff.dat -O -K -P -G0/0/255 -W0/0/255 -Si0.1 >> compare.ps

# add a key
pstext -R -JX -O -K << END >> compare.ps
90.0 570.0 10 0.0 1 1 This study
90.0 540.0 10 0.0 1 1 Malinverno (1991)
90.0 510.0 10 0.0 1 1 Goff (1991 and 1992)
END

# add symbols for the key
# open circle
psxy -R -JX -O -K -W30/225/0 -Sc0.1 << END >> compare.ps
85.0 576.0
END
# closed circle
psxy -R -JX -O -K -Sc0.08 -G255/0/0 -W255/0/0 << END >> compare.ps
85.0 546.0
END
# triangles
psxy -R -JX -O -Si0.1 -W0/0/255 -G0/0/255 << END >> compare.ps
85.0 516.0
END

# view the output
gs -sPAPERSIZE=a4 compare.ps
