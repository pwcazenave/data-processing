#! /bin/csh

set area2=-R330731/331056/-25/-17
set area4=-R0/22/0/30
set proj2=-JX5.3/4
set proj3=-JX22c/30c
set outfile=transect_comparison.ps

gmtset LABEL_FONT_SIZE = 12
gmtset HEADER_FONT_SIZE	= 16p

# map the basemap for the graph
psbasemap $area2 $proj2 -B50:"Eastings":/1:"Depth (m)"::."Depths along the transect":WeSn -K -P -Xc -Yc > $outfile

# plot the graphs of the transect
psxy $proj2 $area2 -O -K -Sp -W255/0/0 hanson_transect_depths.xy >> $outfile
psxy $proj2 $area2 -O -K -Sp -W0/0/255 wessex_transect_depths.xy >> $outfile

# add labels to the graphs and a key
pstext $proj3 $area4 -O -K << TEXT >> $outfile
8.5 9.5 10 0.0 1 1 Hanson Aggregates Marine
8.5 8.9 10 0.0 1 1 Wessex Archaeology Group
TEXT
psxy $proj3 $area4 -O -K -W0/0/255 << BLUE >> $outfile
7.8 9
8.3 9
BLUE
psxy $proj3 $area4 -O -W255/0/0 << RED >> $outfile
7.8 9.6
8.3 9.6
RED

# view the image
gs -sPAPERSIZE=a4 $outfile
