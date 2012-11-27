#! /bin/csh

# plot a couple of transects laterally and longitudinally over the xyz data grid.

set map_area=-R314367/323177/5595340/5599560
set plot_area=-R0/8500/-46/-40
set plot_area_2=-R0/3000/-46/-40
set map_proj=-Jx0.0016
set plot_proj=-JX16/5
set outfile=./images/transects.ps
set long=long_profile.xy
set lat=lat_profile.xy
set long_track=long.trk
set lat_track=lat.trk

# use project to create profile coordinates
#project -C317000/5599000 -E318000/5596000 -G2.5 -N > $lat
#project -C314500/5596450 -E323000/5598750 -G2.5 -N > $long

# plot the bathy
# create the basemap
psbasemap $map_area $map_proj -Xc -Y20 -K -P -B1000/2000:."English Channel Area 473 East - Southern North Sea":.WeSn > $outfile

# create a gradient file for illumination - THIS IS NORMALISED, SO DON'T USE FOR SLOPES!
#grdgradient channel.grd -A250 -Nt0.7 -Gchannel_grad.grd

# plot the grd file
grdimage channel.grd -Ichannel_grad.grd $map_area $map_proj -O -K -Cchannel.cpt -Bg1000 >> $outfile

# add the transects as lines on the bathy
awk '{print $1, $2}' $long | psxy $map_area $map_proj -Bg500 -O -K -H2 -W2/50/0/200 >> $outfile
awk '{print $1, $2}' $lat | psxy $map_area $map_proj -Bg500 -O -K -H2 -W2/200/0/50 >> $outfile

# plot the profiles
psbasemap $plot_area $plot_proj -Ba1000f500g500:"Distance along line (m)":/a2f1g1WeSn:"Depth (m)"::."Depth Profiles Across Area": -X-1 -Y-9 -O -K >> $outfile
#grdtrack $long -Gchannel.grd -V > $long_track
awk '{print $3, $4}' $long_track | psxy $plot_area $plot_proj -O -K -H2 -W1/50/0/200 >> $outfile
psbasemap $plot_area_2 $plot_proj -Ba1000f500g500:"Distance along line (m)":/a2f1g1WeSn:"Depth (m)": -Y-8 -O -K >> $outfile
#grdtrack $lat -Gchannel.grd -V > $lat_track
awk '{print $3, $4}' $lat_track | psxy $plot_area_2 $plot_proj -O -K -H2 -W1/200/0/50 >> $outfile

# display the image
gs -sPAPERSIZE=a4 $outfile
