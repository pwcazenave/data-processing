#! /bin/csh

# script to show the data in 3d...

#set area=`cat ../raw_data/lines_blockmeaned.txt | minmax | awk '{print $5,$6,$7}' | tr "<" " " | tr ">" " " | awk '{printf "%13s %15s %12s\n", $1,$2,$3}' | tr " " "/"`
set area=-R258350/259135/5616067/5616640/24/37
set proj=-Jx0.02
set z_proj=-JZ1
set outfile=./images/3d_ariel_caris.ps

gmtset LABEL_FONT_SIZE 11
gmtset HEADER_FONT_SIZE 14
gmtset HEADER_OFFSET 8

#----------------------------------------------------------------------#

# this is how you automatically determine the minimum and maximum for a given file:
#set area=cat ../raw_data/soc_linesa.txt | tail | minmax | awk '{print $5,$6,$7}' | tr "<" " " | tr ">" " " | awk '{printf "%13s %15s %12s\n", $1,$2,$3}' | tr " " "/" | less

#----------------------------------------------------------------------#

#makecpt -Cocean -T-60/-8/1 -V -Z > maybe_final.cpt
grdview ./ariel_bathy.grd $area $proj $z_proj -Ba200f100g100:"Eastings":/a200f100g100:"Northings":/a5f2.5:"Depth (m)"::."3D Image of the Ariel Wreck":WeSnZ -Iariel_grad.grd -Cariel.cpt -E210/55 -K -Qs -Xc -Yc > $outfile

#----------------------------------------------------------------------#

# view the image:
gs -sPAPERSIZE=a4 $outfile
#ps2pdf $outfile
