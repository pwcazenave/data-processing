#! /bin/csh
set area = -R-20/200/-35/5
set area2 = -R-20/200/5/35
set proj = -JX3.5
set outfile = multirayplot.ps

# top graph
# create a basemap for the graph of the direct and reflected rays

psbasemap $area $proj -B30/5:."Paths of rays (direct and reflected)": -P -K -Y6.3\
-X2.5 -U"Figure 2: Pierre Cazenave" >! $outfile

# plot a horizontal line for the ground surface (green line)

psxy $area $proj -O -K -P -W1/0/255/0 <<END>> $outfile
-20 0
200 0
END

# plot the position of the source (red star)

psxy $area $proj -G255/0/0 -B -Sa0.1 -O -K <<END>> $outfile
1 1
END

# plot a horizontal line representing the reflecting boundary (red
# line)

psxy $area $proj -O -K -P -W1/255/0/0 <<END>> $outfile
200 -30
-20 -30
END

# use more to view the coordinates file, then awk to convert the 
# second column into depth (negative number), and with psxy plot 
# the rays (both direct and reflected). 

more multicoord.dat | awk '{print $1, (-1)*$2}' | psxy $area $proj\
 -BSWSa30:"Distance to Receiver (km)":/5:"Depth (km)": -O -K -P -W1/100/100/100 >> $outfile

# plot the position of the receivers as an inverted triangle

psxy rec_pos.dat $area $proj -B -G0/255/0 -Si0.1 -O -K >> $outfile

# bottom graph
# add a basemap for psxy

psbasemap $area2 $proj -B30/5:."Traveltime for the reflected rays":\
 -P -O -K -Y-5.3 -U"Figure 3: Pierre Cazenave" >> $outfile

# use psxy to plot the traveltimes of the rays

psxy multitime.dat $area2 $proj\
 -BSWSa30:"Distance to Receiver (km)":/5:"Time (s)": -P -N -O >> $outfile

# display the image:

gs -sPAPERSIZE=a4 $outfile
