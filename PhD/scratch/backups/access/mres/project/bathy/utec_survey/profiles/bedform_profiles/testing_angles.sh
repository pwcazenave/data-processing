#! /bin/csh

# script to quickly plot the transect to identify which lines are causing problems...

gmtset LABEL_FONT_SIZE 12
gmtset HEADER_FONT_SIZE 16

set plot_area=-R0/800/-36/-26
set map_area=-R578117/588284/91508/98686
set text_area=-R0/20/0/30
#set map_area=-R578118/596476/91508/104446
set plot_proj=-JX14/8
set map_proj=-Jx0.00125
set text_proj=-JX20/30
set outfile=../../images/profiles/small_dune_zone.ps
set profile=profile_small_dune_zone.trk

# use project to create profile coordinates
project -C583400/94650 -E584075/95000 -G2 -N > $profile

# plot the coordinates of the profiles
psbasemap $map_area $map_proj -Ba2000f1000g500:"Eastings":/a2000f1000g500:"Northings"::."Profile Location":WeSn -Xc -Y16 -K -P > $outfile
grdimage $map_area $map_proj -I../../utec/utec_grad.grd -C../../utec/utec.cpt ../../utec/utec_mask.grd -O -K >> $outfile
awk '{print $1, $2}' $profile | psxy $map_area $map_proj -Bg500 -O -K -H2 -W2/200/0/50 >> $outfile

# plot the profiles
psbasemap $plot_area $plot_proj -Ba200f100g100:"Distance along line (m)":/a2f1g1WeSn:"Depth (m) CD"::."Depth Profile Across Small 2-D Dunes": -X-0.5 -Y-13 -O -K >> $outfile

psscale -D14.1/17/5/0.5 -B5 -C../../utec/utec.cpt -O -K >> $outfile
pstext $text_area $text_proj -O -K -V << TEXT >> $outfile
14 20 12 0 1 1 Depth (m)
TEXT

grdtrack $profile -G../../subsets/sand_waves/grids/utec_mask.grd -V > `basename $profile .trk`.pfl
awk '{print $3, $4}' `basename $profile .trk`.pfl | psxy $plot_area $plot_proj -O -K -H2 -W1/200/0/50 >> $outfile
#\rm temp.file

# view the image
#ps2pdf $outfile
#gs -sPAPERSIZE=a4 $outfile
#kghostview $outfile
