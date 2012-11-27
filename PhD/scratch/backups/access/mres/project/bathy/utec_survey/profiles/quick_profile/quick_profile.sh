#! /bin/csh

# script to quickly plot the transect to identify which lines are causing problems...

gmtset LABEL_FONT_SIZE 12
gmtset HEADER_FONT_SIZE 16

#set area=-R0/5370/-46/-13
set area=-R0/2500/-30/-13
set proj=-JX16/10
set outfile=quick_profile.ps

psbasemap $area $proj -Ba500f250g250:"Distance along line (m)":/a10f5g5WeSn:"Depth (m) CD"::."Hastings Shingle Bank Transect": -Xc -Y15 -P -K >! $outfile
#awk '{print $1, $4}' quick_profile.pts | psxy $area $proj -O -K -H2 -W1/0/0/255 >> $outfile
awk '{print $1, $4}' quick_profile_tide.pts | psxy $area $proj -O -H2 -W1/0/255/0 >> $outfile

# view the image
ps2pdf $outfile
#gs -sPAPERSIZE=a4 $outfile
