#! /bin/csh

# this script will plot 3 graphs: the top plot is a bathymetric plot of the 
# basement picked from within promax and output to a file; the second plot
# shows the roughness of the seabed, which is the fluctuations in the bathymetry
# after the overall slope of the seabed has been removed; the third plot shows
# the variance of the roughness, calculated by squaring the values from the
# roughness. 

set outfile=line107.ps
set proj=-JX12c/5c
set area=-R0/75/-7500/-4500
set area2=-R0/75/-1500/1500
set area3=-R0/75/0/1.6

gmtset ANNOT_FONT_SIZE = 14p
gmtset HEADER_FONT_SIZE = 20p
gmtset LABEL_FONT_SIZE = 12p

# use grep to remove the file headers from the output files from promax.
grep '.0 ' line107.pik > line107a.pik

# use awk to convert the cdp point into metres (distance between cdp points is 6.25m
# and to convert the depths into negative values
awk '{print ((($1-135822)*6.25)/1000), ($2*(-1))}' line107a.pik >! line107neg.pik

# apply a trendline to the data using trend1d
trend1d line107neg.pik -Fxm -N2r >! line107trend.xy

# use trend1d to create a file with the depth residual from trend1d
trend1d line107neg.pik -Fxr -N2r >! line107res.xy

# create, using awk, a file (line107squ.xy) with the residual depth (depth-trend) 
# squared (after Malinverno and Cowie, 1993)
awk '{print $1, ($2**2)}' line107res.xy >! line107squ.xy

# use awk to reduce the values of the squared residuals to allow psxy to plot them
# without using the annotation 1e+06 for numbers greater than a million
awk '{print $1, ($2/1000000)}' line107squ.xy >! line107squsma.xy

# create a basemap for the psxy graph to sit in
psbasemap $area $proj -B10/500WeSn:."Basement Depth": -Xc -Y8 -P -K >! $outfile

# add text to the basemap for the letter of the graph 
# (e.g. Figure #a, #b, or #c)
pstext $area $proj -O -K << END >> $outfile
1.0 -4750.0 10 0.0 1 1 a)
END

# use psxy to plot the roughness of the basement extracted from the segy file
# using the promax pick tool and exported into a text file (line107.pik), and 
# whose depths were subsequently turned from positive into negative depths and 
# written to the file line107neg.pik.
psxy $area $proj line107neg.pik -BSWSa10:"Distance along line (km)":/500:"Depth (m)":\
 -O -K -P -W1/0/200/30 >> $outfile

# plot the trendline on the graph
psxy $area $proj line107trend.xy -O -K -P -W1/0/0/0 >> $outfile

# add a second basemap for the middle graph
psbasemap $area2 $proj -B10/500WeSn:."Basement Roughness": -Y-3.5 -P -O\
-K >> $outfile

# add the graph letter in pstext
pstext $area2 $proj -O -K << END >> $outfile
1.0 1250.0 10 0.0 1 1 b)
END

# plot a horizontal line at zero (dotted line)
psxy $area2 $proj -O -K -P -W1/0/0/0t20:20 <<END>> $outfile
0 0
75 0
END

# use psxy to plot the residual depth (line107res.pik)
psxy $area2 $proj line107res.xy -BSWSa10:"Distance along line (km)":/500:"Roughness (m)":\
-O -K -P -W1/255/0/0 >> $outfile

# add a third basemap for the bottom graph
psbasemap $area3 $proj -B10/0.2/WeSn:."Variance of the Residual Depth":\
-U"Line107" -Y-3.5 -P -O -K >> $outfile

# add the graph letter in pstext and the rms roughness value for this line
pstext $area3 $proj -O -K << END >> $outfile
1.0 1.45 10 0.0 1 1 c)
60.0 1.45 10 0.0 1 1 r.m.s = 521m
END

# plot the squared residuals (line107squsma.xy)
psxy $area3 $proj line107squsma.xy -BSWSa10:"Distance along line (km)":/0.2:"(Depth-Trend)@+2@+ (millions of m@+2@+)":\
-O -P -W1/0/0/255 >> $outfile

# view the postscript file
gs -sPAPERSIZE=a4 $outfile