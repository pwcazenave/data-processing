#!/bin/bash

# script to plot the explanatory fft figures for the caris talk

gmtset ANNOT_FONT_SIZE=18 LABEL_FONT_SIZE=18

area1d=-R-0.2/0.2/0/1
areasine=-R0/200/-2.5/2.5
area2d=-R-0.2/0.2/-0.2/0.2/0/1
area2db=-R-0.2/0.2/-0.2/0.2
proj1d=-JX23/16
proj2da=-JX14/14
proj2db=-JZ10

gres=0.5
dir1=60

sineout=./images/synthetic/synthetic_flat_${gres}m_dir_${dir1}_sine.ps
out1d=./images/synthetic/synthetic_flat_${gres}m_dir_${dir1}_1d.ps
out15d=./images/synthetic/synthetic_flat_${gres}m_dir_${dir1}_1.5d.ps
out2d=./images/synthetic/synthetic_flat_${gres}m_dir_${dir1}_2d_no_vector.ps
out3d=./images/synthetic/synthetic_flat_${gres}m_dir_${dir1}_3d.ps

formats(){
   echo -n "converting to pdf "
   ps2pdf -sPAPERSIZE=a4 -dPDFSETTINGS=/prepress -q $1 \
      ${1%.ps}.pdf
   echo -n "and jpeg... "
   gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q \
      -sOutputFile=${1%.ps}.jpg $1
   echo "done."
}

fixem(){
   echo -n "convert from dos to unix... "
   dos2unix ./raw_data/synthetic/synthetic_flat_*fft*.txt \
   ./raw_data/synthetic/synthetic_flat_*sine*.txt \
      &> /dev/null
   echo "done."
}

singles(){
   echo -n "make single files... "
   paste ./raw_data/synthetic/synthetic_flat_${gres}m_dir_${dir1}_sine_x.txt \
      ./raw_data/synthetic/synthetic_flat_${gres}m_dir_${dir1}_sine_z.txt \
      > ./raw_data/synthetic/synthetic_flat_${gres}m_dir_${dir1}_sine.txt

   paste ./raw_data/synthetic/synthetic_flat_${gres}m_dir_${dir1}_fft_x.txt \
      ./raw_data/synthetic/synthetic_flat_${gres}m_dir_${dir1}_1d1.5dfft_z.txt \
      > ./raw_data/synthetic/synthetic_flat_${gres}m_dir_${dir1}_1d.txt

   paste ./raw_data/synthetic/synthetic_flat_${gres}m_dir_${dir1}_fft_x.txt \
      ./raw_data/synthetic/synthetic_flat_${gres}m_dir_${dir1}_fft_y_angled.txt \
      ./raw_data/synthetic/synthetic_flat_${gres}m_dir_${dir1}_1d1.5dfft_z.txt \
      > ./raw_data/synthetic/synthetic_flat_${gres}m_dir_${dir1}_1.5d.txt

   paste ./raw_data/synthetic/synthetic_flat_${gres}m_dir_${dir1}_2dfft_x.txt \
      ./raw_data/synthetic/synthetic_flat_${gres}m_dir_${dir1}_2dfft_y.txt \
      ./raw_data/synthetic/synthetic_flat_${gres}m_dir_${dir1}_2dfft_z.txt \
      > ./raw_data/synthetic/synthetic_flat_${gres}m_dir_${dir1}_2d.txt
   echo "done."
}

mkgrid(){
   echo -n "make the 2d fft grid... "
#   xyz2grd -I0.001 $area2db \
   surface -I0.0015 $area2db -T0.25 \
      ./raw_data/synthetic/synthetic_flat_${gres}m_dir_${dir1}_2d.txt \
      -G./grids/synthetic/synthetic_flat_${gres}m_dir_${dir1}_2d.grd
   echo "done."
}

plot(){
   echo -n "plot all the graphs... "
   psxy $areasine $proj1d -W5/0/0/0 -Xc -Yc \
      -Ba20f5g20:"Distance Along Transect (m)":/a0.5f0.1g5:"Depth (m)":WeSn \
      ./raw_data/synthetic/synthetic_flat_${gres}m_dir_${dir1}_sine.txt \
      > $sineout
   
   psxy $area1d $proj1d -W5/0/0/0 -Xc -Yc \
      -Ba0.1f0.05g0.1:"Kx (m)":/a0.2f0.04g0.2:"|| Power ||":WeSn \
      ./raw_data/synthetic/synthetic_flat_${gres}m_dir_${dir1}_1d.txt \
      > $out1d
   
   awk '{if ($1>-0.2 && $1<0.2 && $2>-0.2 && $2<0.2 || $3>0) print $0}' \
      ./raw_data/synthetic/synthetic_flat_${gres}m_dir_${dir1}_1.5d.txt | \
      psxyz $area2d $proj2da $proj2db -W5/0/0/0 -Xc -Yc -E155/45 \
      -Ba0.1f0.05g0.1:"Kx (m)":/a0.1f0.05g0.1:"Ky (m)":/a0.2f0.04g0.1:"|| Power ||":wESnZ \
      > $out15d
   
   makecpt -T-0.2/1/0.1 -Z -Cno_green > ./cpts/synthetic.cpt 2> /dev/null
#   grd2cpt $area2db -Cno_green -T- \
#      ./grids/synthetic/synthetic_flat_${gres}m_dir_${dir1}_2d.grd \
#      > ./cpts/synthetic.cpt
   grdview $area2d $proj2da $proj2db -E155/45 -Xc -Yc \
      ./grids/synthetic/synthetic_flat_${gres}m_dir_${dir1}_2d.grd \
      -Ba0.1f0.05g0.1:"Kx (m)":/a0.1f0.05g0.1:"Ky (m)":/a0.2f0.04g0.1:"|| Power ||":wESnZ \
      > $out3d

   grdimage $area2db $proj2da -Xc -Yc -K \
      -Ba0.1f0.05g0.1:"Kx (m)":/a0.1f0.05g0.1:"Ky (m)":WeSn \
      ./grids/synthetic/synthetic_flat_${gres}m_dir_${dir1}_2d.grd \
      -C./cpts/synthetic.cpt \
      > $out2d
   psscale -D16/6.5/7/0.5 -C./cpts/synthetic.cpt -Ba0.2f0.05 -O -K \
      >> $out2d
   pstext $area2db $proj2da -N -O << POWER >> $out2d
   0.25 0.11 18 0 0 1 || Power ||
POWER
   echo "done."
}

vectors(){
   infile=./raw_data/synthetic/synthetic_flat_${gres}m_dir_${dir1}_2d.txt
   # +ve err
   awk '{if (NR==1) print 0,0,60.9025+0.8258,0.1*39}' $infile | \
      psxy $area2db $proj2da -SVT0.1/0.1/0.1 -O -K -G255/255/255 \
      >> $out2d
   # -ve err
   awk '{if (NR==1) print 0,0,60.9025+0.8258,0.1*39}' $infile | \
      psxy $area2db $proj2da -SVT0.1/0.1/0.1 -O -K -G255/255/255 \
      >> $out2d
   # vector
   awk '{if (NR==1) print 0,0,60.9025+0.8258,0.1*39}' $infile | \
      psxy $area2db $proj2da -SVT0.1/0.1/0.1 -O -G128/128/128 \
      >> $out2d
}

all_formats(){
   formats $sineout
   formats $out1d
   formats $out15d
   formats $out2d
   formats $out3d
}


fixem
singles
mkgrid
plot
vectors
all_formats
