#! /bin/csh
set area = -R-20/200/-40/10
set proj = -JX5
set outfile = rayplot.ps

# create a basemap for the graph of the direct and reflected ray

psbasemap $area $proj -B30/10:."Paths of Rays (Direct and Reflected)":\
 -P -K -Y5 -X1.5 -U"Figure 1: Pierre Cazenave" >! $outfile

# plot a horizontal line for the ground surface (green line)

psxy $area $proj -O -K -P -W1/0/255/0 <<END>> $outfile
-20 0
200 0
END

# plot the position of the source (red circle)

psxy $area $proj -G255/0/0 -B -Sa0.1 -O -K <<END>> $outfile
1 1
END

# plot a horizontal line representing the reflecting boundary (red
# line)

psxy $area $proj -O -K -P -W1/255/0/0 <<END>> $outfile
200 -30
-20 -30
END

# add a symbol (inverted triangle) for the position of the receiver

psxy $area $proj -G0/255/0 -B -Si0.1 -O -K <<END>> $outfile
101 1
END

# use more to view the file, then awk to convert the second column
# into depth (negative number), and with psxy plot the rays (both
# direct and reflected). 

more coord.dat | awk '{print $1, (-1)*$2}' | psxy $area $proj\
 -BSWSa30:"Distance to Receiver (km)":/1000:"Depth (km)": -O -K -P -W1/100/100/100 >> $outfile

# display the image:

gs -sPAPERSIZE=a4 $outfile
