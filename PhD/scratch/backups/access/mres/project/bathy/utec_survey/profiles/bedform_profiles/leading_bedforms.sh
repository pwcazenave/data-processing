#! /bin/csh

# plot bedform profiles

gmtset LABEL_FONT_SIZE 12
gmtset HEADER_FONT_SIZE 16

set plot_area=-R0/1520/-40/-35
set map_area=-R578117/588284/91508/98686
#set map_area=-R578118/596476/91508/104446
set plot_proj=-JX14/8
set map_proj=-JX13/8.8
set outfile=../../images/profiles/leading_bedforms.ps
set profile=profile_leading_bedforms.trk

# use project to create profile coordinates
project -C585250/95225 -E586400/96200 -G2 -N > $profile

# plot the coordinates of the profiles
psbasemap $map_area $map_proj -Ba2000f1000g500:"Eastings":/a2000f1000g500:"Northings"::."Profile Locations":WeSn -Xc -Y16 -K -P > $outfile
grdimage $map_area $map_proj -I../../utec/utec_grad.grd -C../../utec/utec.cpt ../../utec/utec_mask.grd -O -K >> $outfile
awk '{print $1, $2}' $profile | psxy $map_area $map_proj -Bg500 -O -K -H2 -W2/200/0/50 >> $outfile

# plot the profiles
psbasemap $plot_area $plot_proj -Ba500f250g250:"Distance along line (m)":/a1f0.5g0.5WeSn:"Depth (m) CD"::."Depth Profile Across Medium 2-D Dunes": -X-0.5 -Y-13 -O -K >> $outfile

grdtrack $profile -G../../subsets/leading_bedforms/grids/utec_mask.grd -V > `basename $profile .trk`.pfl
awk '{print $3, $4}' `basename $profile .trk`.pfl | psxy $plot_area $plot_proj -O -K -H2 -W1/200/0/50 >> $outfile

# view the image
#ps2pdf $outfile
#gs -sPAPERSIZE=a4 $outfile
#kghostview $outfile
