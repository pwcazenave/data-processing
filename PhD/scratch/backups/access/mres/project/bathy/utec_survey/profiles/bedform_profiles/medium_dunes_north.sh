#! /bin/csh

# plot bedform profiles

gmtset LABEL_FONT_SIZE 12
gmtset HEADER_FONT_SIZE 16

set plot_area=-R0/100/-23.5/-23
set map_area=-R578117/588284/91508/98686
set text_area=-R0/20/0/30
#set map_area=-R578118/596476/91508/104446
set plot_proj=-JX14/8
set map_proj=-Jx0.00125
set text_proj=-JX20/30
set outfile=../../images/profiles/medium_dunes_north.ps
set profile=profile_medium_dunes_north.trk
#set profile2=profile__medium_dunes_north2.trk

# use project to create profile coordinates
#project -C582000/97200 -E582343/97405.8 -G0.25 -N > $profile
project -C582411/97703.6 -E582500/97750 -G0.25 -N > $profile 
#project -C583800/98000 -E584800/98500 -G2 -N > $profile2

# plot the coordinates of the profiles
psbasemap $map_area $map_proj -Ba2000f1000g500:"Eastings":/a2000f1000g500:"Northings"::."Profile Location":WeSn -Xc -Y16 -K -P > $outfile
grdimage $map_area $map_proj -I../../utec/utec_grad.grd -C../../utec/utec.cpt ../../utec/utec_mask.grd -O -K >> $outfile
awk '{print $1, $2}' $profile | psxy $map_area $map_proj -Bg500 -O -K -H2 -W2/50/0/200 >> $outfile
#awk '{print $1, $2}' $profile2 | psxy $map_area $map_proj -Bg500 -O -K -H2 -W2/50/0/200 >> $outfile

# plot the profiles
psbasemap $plot_area $plot_proj -Ba50f10g10:"Distance along line (m)":/a0.1f0.05g0.05WeSn:"Depth (m) CD"::."Depth Profile Across Medium 2-D Dunes": -X-0.5 -Y-13 -O -K >> $outfile

psscale -D14.1/17/5/0.5 -B5 -C../../utec/utec.cpt -O -K >> $outfile
pstext $text_area $text_proj -O -K -V << TEXT >> $outfile
14 20 12 0 1 1 Depth (m)
TEXT

grdtrack $profile -G../../subsets/north_eastern_deep/grids/utec_mask.grd -V > `basename $profile .trk`.pfl
awk '{print $3, $4}' `basename $profile .trk`.pfl | psxy $plot_area $plot_proj -O -K -H2 -W1/50/0/200 >> $outfile
#grdtrack $profile2 -G../../subsets/northern_waves/utec_mask.grd -V | awk '{print $3, $4}' | psxy $plot_area $plot_proj -O -K -H2 -W1/50/0/200 >> $outfile

# view the image
#ps2pdf $outfile
#gs -sPAPERSIZE=a4 $outfile
#kghostview $outfile
