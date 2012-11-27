#!/bin/csh -f

# script to plot my algorithm output as a 3d graph

# get the basics in:
set area=-R-160/160/0/1000/25/50
set proj=-JX20/15
set z_proj=-JZ-5

# i/o
set infile=../swaths.xy
set outfile=./images/bathy.ps

##----------------------------------------------------------------------------##

# format the data
grep -v beam $infile | awk '{if ($3!=0) print $3, $1, $4, $4*10}' > input.xyz

# make a colour palette file
makecpt -Cwysiwyg -T300/500/0.01 -Z -I > .model.cpt

# plot the swath data
psxyz $area $proj $z_proj -K -Ba20f10g20:"Distance from nadir (m)":/a100f50g100:"Ping":/a5f2.5:"Depth (m)":wESnZ -E140/40 -Sc0.05 -C.model.cpt input.xyz > $outfile

# add a single beam connected by a line
grep -v beam $infile | awk '{if ($2==96.0) print $3, $1, $4, $4*10}' > 3d_single_beam_96.xyz
psxyz $area $proj $z_proj -O -K -B0 -E140/40 3d_single_beam_96.xyz -W2/255/20/147 >> $outfile

##----------------------------------------------------------------------------##

# display the image
# gs -sPAPERSIZE=a4 $outfile
ps2pdf -sPAPERSIZE=a4 $outfile
