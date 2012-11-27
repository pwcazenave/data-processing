#!/bin/csh -f

# script to plot my algorithm output as a 3d graph

# get the basics in:
set area=-R-160/160/0/100/38/43
set proj=-JX20/15
set z_proj=-JZ-5

# i/o
set pitch_infile=../swaths_pitch.xyz
set pitch_outfile=./images/pitch.ps

##----------------------------------------------------------------------------##

# format the data
grep -v beam $pitch_infile | awk '{if ($3!=0) print $3, $1, $4, $4*10}' > input.xyz

# make a colour palette file
makecpt -Cwysiwyg -T390/430/0.01 -Z -I > .model.cpt

# plot the swath data
psxyz $area $proj $z_proj -K -Ba20f10g20:"Distance from nadir (m)":/a10f5g10:"Ping":/a5f2.5:"Depth (m)":wESnZ -E140/40 -Sc0.05 -C.model.cpt input.xyz > $pitch_outfile

# add a single beam connected by a line
grep -v beam $pitch_infile | awk '{if ($2==100.0) print $3, $1, $4, $4*10}' > pitch_3d_single_beam_96.xyz
psxyz $area $proj $z_proj -O -K -B0 -E140/40 pitch_3d_single_beam_96.xyz -W2/255/20/147 >> $pitch_outfile

##----------------------------------------------------------------------------##

# display the image
# gs -sPAPERSIZE=a4 $pitch_outfile
ps2pdf -sPAPERSIZE=a4 $pitch_outfile
