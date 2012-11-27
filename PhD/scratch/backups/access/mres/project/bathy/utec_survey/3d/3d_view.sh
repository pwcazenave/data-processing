#! /bin/csh

# script to show the data in 3d... 

#set area=`cat ../raw_data/lines_blockmeaned.txt | minmax | awk '{print $5,$6,$7}' | tr "<" " " | tr ">" " " | awk '{printf "%13s %15s %12s\n", $1,$2,$3}' | tr " " "/"`
set area=-R578106/588290/91506/98686/-50/-13
set proj=-JX10
set z_proj=-JZ2.5
set outfile=hastings.ps

gmtset LABEL_FONT_SIZE 11
gmtset HEADER_FONT_SIZE 14
gmtset HEADER_OFFSET 8

#----------------------------------------------------------------------#

# this is how you automatically determine the minimum and maximum for a given file:
#set area=cat ../raw_data/soc_linesa.txt | tail | minmax | awk '{print $5,$6,$7}' | tr "<" " " | tr ">" " " | awk '{printf "%13s %15s %12s\n", $1,$2,$3}' | tr " " "/" | less

#----------------------------------------------------------------------#

makecpt -Cocean -T-60/-8/1 -V -Z > maybe_final.cpt
grdview ../utec/utec_mask.grd $area $proj $z_proj -Ba2000f1000g1000:"Eastings":/a2000f1000g1000:"Northings":/a20f10:"Depth (m)"::."3D Image of Hastings Shingle Bank":wESnZ -I../utec/utec_grad.grd -C../utec/utec.cpt -E130/35 -K -Qs -P -X3 -Yc -V >! $outfile

#----------------------------------------------------------------------#

# view the image:
gs -sPAPERSIZE=a4 $outfile
#ps2pdf $outfile
