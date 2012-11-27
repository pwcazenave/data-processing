#!/bin/bash

# script to plot the output of the matlab code on top of the appropriate grid

#set -x

gres=0.5
dir1=60
dir2=75
proj=0.08
area=0/200/0/200

prefix=synthetic_flat_${gres}m_dir_${dir1}_${dir2}
infile=./raw_data/synthetic/${prefix}.txt

grid=./grids/synthetic/${prefix}.grd
grad=./grids/synthetic/${prefix}_grad.grd
cpt=./${prefix}.cpt

formats(){
   echo -n "converting to pdf "
   ps2pdf -sPAPERSIZE=a4 -dPDFSETTINGS=/prepress -q $1 \
      ${1%.ps}.pdf
   echo -n "and jpeg... "
   gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q \
      -sOutputFile=${1%.ps}.jpg $1
   echo "done."
}

mkgrids(){
   echo -n "make a bathy grid... "
#   dos2unix ./raw_data/synthetic/${prefix}_*.txt &> /dev/null
   dos2unix ./raw_data/synthetic/${prefix}_x.txt \
      ./raw_data/synthetic/${prefix}_y.txt \
      ./raw_data/synthetic/${prefix}_z.txt \
      ./raw_data/synthetic/${prefix}_mwd.txt \
      ./raw_data/synthetic/${prefix}_std_dir.txt \
      ./raw_data/synthetic/${prefix}_mwl.txt \
      ./raw_data/synthetic/${prefix}_std_wl.txt \
      ./raw_data/synthetic/${prefix}_mwh.txt \
      ./raw_data/synthetic/${prefix}_std_amp.txt &> /dev/null
   paste ./raw_data/synthetic/${prefix}_x.txt \
      ./raw_data/synthetic/${prefix}_y.txt \
      ./raw_data/synthetic/${prefix}_z.txt \
      ./raw_data/synthetic/${prefix}_mwd.txt \
      ./raw_data/synthetic/${prefix}_std_dir.txt \
      ./raw_data/synthetic/${prefix}_mwl.txt \
      ./raw_data/synthetic/${prefix}_std_wl.txt \
      ./raw_data/synthetic/${prefix}_mwh.txt \
      ./raw_data/synthetic/${prefix}_std_amp.txt \
      > $infile

   xyz2grd -I$gres -R$area $infile -G${grid}
   grdgradient -Nt0.9 -A250 $grid -G${grad}
   echo "done."
}


plot(){
   makecpt -Crainbow -T-3/3/0.1 > $cpt

   echo -n "bathy for synthetic... "
   grdimage -R$area -Jx$proj $grid \
      -I$grad \
      -C$cpt \
      -Ba20f5:Metres\ East:/a20f5:Metres\ North:WeSn \
      -Xc -Yc -K \
      > ./images/synthetic/${prefix}_bathy.ps
   psscale -I -D17/8/7/0.5 -Ba1f0.2:"Depth (m)": \
      -C$cpt -O \
      >> ./images/synthetic/${prefix}_bathy.ps
      echo "done."

   formats ./images/synthetic/${prefix}_bathy.ps

   echo -n "working on $infile... "

   outfile=./images/synthetic/$(basename $infile .txt).ps
      
   grdimage -R$area -Jx${proj} $grid \
      -I$grad \
      -C$cpt \
      -Ba20f5:Metres\ East:/a20f5:Metres\ North:WeSn \
      -Xc -Yc -K > $outfile
   psscale -I -D17/8/7/0.5 -Ba1f0.2:"Depth (m)": \
      -C$cpt -O -K >> $outfile
   # +ve err
   awk '{if (NR==1) print $1+100,$2+100,$4+$5,$6*('$proj'*2)}' $infile | \
      psxy -R$area -Jx$proj -SVT0.1/0.1/0.1n0.5 -O -K -G255/255/255 \
      >> $outfile
   # -ve err
   awk '{if (NR==1) print $1+100,$2+100,$4-$5,$6*('$proj'*2)}' $infile | \
      psxy -R$area -Jx$proj -SVT0.1/0.1/0.1n0.5 -O -K -G255/255/255 \
      >> $outfile
      # vector
   awk '{if (NR==1) print $1+100,$2+100,$4,$6*('$proj'*2)}' $infile | \
      psxy -R$area -Jx$proj -SVT0.1/0.1/0.1n0.5 -O -G0/0/0 \
      >> $outfile
   echo "done."

   formats $outfile
}

mk_kk(){
   echo -n "prepare the kk data... "
   dos2unix ./raw_data/synthetic/${prefix}_power_*.txt &> /dev/null
   paste ./raw_data/synthetic/${prefix}_power_x.txt \
      ./raw_data/synthetic/${prefix}_power_y.txt \
      ./raw_data/synthetic/${prefix}_power_z.txt \
      > ./raw_data/synthetic/${prefix}_kk.txt
   xyz2grd -I0.003 -R-1/1/-1/1 ./raw_data/synthetic/${prefix}_kk.txt \
      -G./grids/synthetic/${prefix}_kk.grd
   echo "done."
}

plot_kk(){
   echo -n "plot the kk data... "
   kk_out=./images/synthetic/${prefix}_kk_no_vector.ps
   makecpt -T-0.2/1/0.1 -Cno_green > ./cpts/kk.cpt
   grdimage -R-0.2/0.2/-0.2/0.2 -Jx39 ./grids/synthetic/${prefix}_kk.grd \
      -Xc -Yc -K -Ba0.1f0.02g0.1:"Kx":/a0.1f0.02g0.1:"Ky":WeSn -C./cpts/kk.cpt \
      > $kk_out
   # +ve err
#   awk '{if (NR==1) print $1,$2,$4+$5,0.1*39}' $infile | \
#      psxy -R -J -SVT0.1/0.1/0.1 -O -K -G255/255/255 \
#      >> $kk_out
  # -ve err
#   awk '{if (NR==1) print $1,$2,$4-$5,0.1*39}' $infile | \
#      psxy -R -J -SVT0.1/0.1/0.1 -O -K -G255/255/255 \
#      >> $kk_out
     # vector
#   awk '{if (NR==1) print $1,$2,$4,0.1*39}' $infile | \
#      psxy -R -J -SVT0.1/0.1/0.1 -O -K -G128/128/128 \
#      >> $kk_out
   
   psscale -D17/8/7/0.5 -C./cpts/kk.cpt -Ba0.2f0.05 -O -K \
      >> $kk_out
   pstext -R -J -N -O << POWER >> $kk_out
   0.227 0.12 18 0 0 1 || Power ||
POWER
#   psscale -D17/8/7/0.5 -Ba0.2f0.05:"Normalised Power": \
#      -C./cpts/kk.cpt -O \
#      >> $kk_out
   echo "done."
   
   formats $kk_out
}

mkgrids
plot
mk_kk
plot_kk
