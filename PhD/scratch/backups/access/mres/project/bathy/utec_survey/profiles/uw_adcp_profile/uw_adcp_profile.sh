#! /bin/csh -f

# script to quickly plot the transect to identify which lines are causing problems...

gmtset LABEL_FONT_SIZE 12
gmtset HEADER_FONT_SIZE 16

set area=-R0/3285/-31/-14
set proj=-JX14/8
set outfile=adcp_uw_profile.ps

# make the profile
project -C583705.72/97026.37 -E582840.55/94769.86 -G0.25 -N > 1to2.trk
project -C582840.55/94769.86 -E582994.55/93915.92 -G0.25 -N > 2to3.trk

# plot the profiles

psbasemap $area $proj -Ba500f250g250:"Distance along line (m)":/a5f2.5g2.5WeSn:"Depth (m) CD"::."Depth Profile from the Unknown Wreck through the ADCP Sites": -Xc -Y16 -P -K >! $outfile
#awk '{print $1, $4}' 2_point_uw_adcp_transect.pts | psxy $area $proj -O -K -H2 -W1/200/0/50 >> $outfile
#awk '{print $1, $4}' 3_point_uw_adcp_transect.pts | psxy $area $proj -O -K -H2 -W1/50/0/200 >> $outfile
#cat 1to2.trk 2to3.trk | awk '{print $1, $2}' | psxy $area $proj -O -K -H2 -W1/50/0/200 >> $outfile
cat 1to2.trk 2to3.trk2 | grdtrack -G../../utec/utec_mask.grd > transect.xz
awk '{print $3, $4}' transect.xz | psxy $area $proj -O -K -H2 -W1/50/0/200 >> $outfile

# plot the coordinates of the profiles

set map_area=-R581517/584833/93405/97643
set map_proj=-JX6.7/9

psbasemap $map_area $map_proj -Ba1000f500:"Eastings":/a500:"Northings"::."Profile locations":WeSn -X3.5 -Y-13 -O -K >> $outfile
grdimage $map_area $map_proj -I../../utec/utec_grad.grd -C../../utec/utec.cpt ../../utec/utec_mask.grd -O -K >> $outfile
#awk '{print $2, $3}' 2_point_uw_adcp_transect.pts | psxy $map_area $map_proj -Bg500 -O -K -H2 -W2/200/0/50 >> $outfile

# cat the two profiles together and then plot them
cat 1to2.trk 2to3.trk | grdtrack -G../../utec/utec_mask.grd | awk '{print $1, $2}' | psxy $map_area $map_proj -O -K -H2 -W1/50/0/200 >> $outfile

#awk '{print $2, $3}' 3_point_uw_adcp_transect.pts | psxy $map_area $map_proj -Bg500 -O -H2 -W2/50/0/200 >> $outfile

# view the image
#ps2pdf $outfile
#gs -sPAPERSIZE=a4 $#outfile
