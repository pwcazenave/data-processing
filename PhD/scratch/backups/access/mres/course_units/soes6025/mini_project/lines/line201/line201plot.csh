#! /bin/csh

# this script will plot 3 graphs: the top plot is a bathymetric plot of the 
# basement picked from within promax and output to a file; the second plot
# shows the roughness of the seabed, which is the fluctuations in the bathymetry
# after the overall slope of the seabed has been removed; the third plot shows
# the variance of the roughness, calculated by squaring the values from the
# roughness. 

set outfile=line201.ps
set proj=-JX12c/5c
set area=-R0/68/-7500/-5500
set area2=-R0/68/-1000/1000
set area3=-R0/68/0/0.7

gmtset ANNOT_FONT_SIZE = 14p
gmtset HEADER_FONT_SIZE = 20p
gmtset LABEL_FONT_SIZE = 12p

# use grep to remove the file headers from the output files from promax.
grep '.0 ' line201.pik > line201a.pik

# use awk to convert the cdp point into metres (distance between cdp points is 6.25m
# and to convert the depths into negative values
awk '{print ((($1-252506)*6.25)/1000), ($2*(-1))}' line201a.pik >! line201neg.pik

# apply a trendline to the data using trend1d
trend1d line201neg.pik -Fxm -N2r >! line201trend.xy

# use trend1d to create residual of depth minus trend
trend1d line201neg.pik -Fxr -N2r >! line201res.xy

# create, using awk, a file (line201squ.xy) with the residual depth (depth-trend) 
# squared (after Malinverno and Cowie, 1993)
awk '{print $1, ($2**2)}' line201res.xy >! line201squ.xy

# use awk to reduce the values of the squared residuals to allow psxy to plot them
# without using the annotation 1e+06 for numbers greater than a million
awk '{print $1, ($2/1000000)}' line201squ.xy >! line201squsma.xy

# create a basemap for the graphs to sit in
psbasemap $area $proj -B10/500WeSn:."Basement Depth": -Xc -Y8 -P -K >! $outfile

# add text to the basemap for the letter of the graph 
# (e.g. Figure #a, #b, or #c)
pstext $area $proj -O -K << END >> $outfile
1.0 -5700.0 10 0.0 1 1 a)
END

# use psxy to plot the roughness of the basement extracted from the segy file
# using the promax pick tool and exported into a text file (pickstry2)
psxy $area $proj line201neg.pik -BSWSa10:"Distance along line (km)":/500:"Depth (m)":\
 -O -K -P -W1/0/200/30 >> $outfile

# plot the trendline on the graph
psxy $area $proj line201trend.xy -O -K -P -W1/0/0/0 >> $outfile

# add a second basemap for the middle graph
psbasemap $area2 $proj -B10/500WeSn:."Basement Roughness": -Y-3.5 -P -O\
-K >> $outfile

# add the graph letter in pstext
pstext $area2 $proj -O -K << END >> $outfile
1.0 825.0 10 0.0 1 1 b)
END

# plot a horizontal line at zero (dotted line)
psxy $area2 $proj -O -K -P -W1/0/0/0t20:20 <<END>> $outfile
0 0
136 0
END

# use psxy to plot the residual depth (line201res.xy)
psxy $area2 $proj line201res.xy -BSWSa10:"Distance along line (km)":/500:"Roughness (m)":\
-O -K -P -W1/255/0/0 >> $outfile

# add a third basemap for the bottom graph
psbasemap $area3 $proj -B10/0.2WeSn:."Variance of the Residual Depth":\
-U"Line201" -Y-3.5 -P -O -K >> $outfile

# add the graph letter in pstext and the rms roughness value for this line
pstext $area3 $proj -O -K << END >> $outfile
1.0 0.63 10 0.0 1 1 c)
53.0 0.63 10 0.0 1 1 r.m.s = 368m
END

# plot the squared residuals (line201squ.xy)
psxy $area3 $proj line201squsma.xy -BSWSa10:"Distance along line (km)":/0.2:"(Depth-Trend)@+2@+ (millions of m@+2@+)":\
-O -P -W1/0/0/255 >> $outfile

# view the postscript file
gs -sPAPERSIZE=a4 $outfile