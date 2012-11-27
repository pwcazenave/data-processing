#!/bin/bash

# script to plot the output of the matlab code on top of the appropriate grid

#set -x

west=(579000 585900 586000 582500 583500)
east=(579750 586700 587000 583400 584300)
south=(97000 96200 97000 93900 95450)
north=(97750 97000 98000 94800 96250)

zones=(1 2 3 4 5)
cutoff=15
gres=1

proj=(0.022 0.021 0.017 0.018 0.021)
min_depth=(-21 -39 -36 -36 -23)
max_depth=(-17 -16 -12 -18 -15)
sample=(35 70 110 150 185)
interval=(1 5 5 5 2) # psscale label intervals
frame=(0.25 1 1 1 0.5) # psscale frame tick intervals

formats(){
   echo -n "converting to pdf "
   ps2pdf -sPAPERSIZE=a4 -dPDFSETTINGS=/prepress -q $1 \
      ${1%.ps}.pdf
   echo -n "and jpeg... "
   gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q \
      -sOutputFile=${1%.ps}.jpg $1
   echo "done."
}

plot(){
   for ((i=0; i<${#zones[@]}; i++)); do

      area=-R${west[i]}/${east[i]}/${south[i]}/${north[i]}
         
      grid=./grids/regions/hsb_2005_large_${zones[i]}_*[0-9].grd
      grad=./grids/regions/hsb_2005_large_${zones[i]}_*[0-9]_grad.grd
      cpt=./cpts/hsb_2005_large_${zones[i]}*.cpt
      
      makecpt -Crainbow -T${min_depth[i]}/${max_depth[i]}/0.1 > $cpt

      echo -n "bathy for zone ${zones[i]} ... "
      grdimage $area -Jx${proj[i]} $grid \
         -I$(echo $grad) \
         -C$(echo $cpt) \
         -Ba200f50:Eastings:/a200f50:Northings:WeSn \
         -Xc -Yc -K \
         > ./images/gmt/zone${zones[i]}_${gres}m_${cutoff}m_cutoff_bathy.ps
      psscale -I -D18/8/7/0.5 -Ba${interval[i]}f${frame[i]}:"Depth (m)": \
         -C$(echo $cpt) -O \
         >> ./images/gmt/zone${zones[i]}_${gres}m_${cutoff}m_cutoff_bathy.ps
      echo "done."

      formats ./images/gmt/zone${zones[i]}_${gres}m_${cutoff}m_cutoff_bathy.ps

      for ((j=0; j<${#sample[@]}; j++)); do
         prefix=zone${zones[i]}_${sample[j]}m_${gres}m_${cutoff}m_cutoff
         dos2unix ./raw_data/matlab_results/${prefix}_*.txt &> /dev/null
         infile=./raw_data/matlab_results/${prefix}.txt
         paste ./raw_data/matlab_results/${prefix}_x.txt \
            ./raw_data/matlab_results/${prefix}_y.txt \
            ./raw_data/matlab_results/${prefix}_mwd.txt \
            ./raw_data/matlab_results/${prefix}_std_dir.txt \
            ./raw_data/matlab_results/${prefix}_mwl.txt \
            ./raw_data/matlab_results/${prefix}_std_wl.txt \
            ./raw_data/matlab_results/${prefix}_mwh.txt \
            ./raw_data/matlab_results/${prefix}_std_amp.txt \
            > ${infile}

         outfile=./images/gmt/$(basename $infile .txt).ps
         
         echo -n "working on $infile... "
   
         grdimage $area -Jx${proj[i]} $grid \
            -I$(echo $grad) \
            -C$(echo $cpt) \
            -Ba200f50:Eastings:/a200f50:Northings:WeSn \
            -Xc -Yc -K > $outfile
         psscale -I -D18/8/7/0.5 -Ba${interval[i]}f${frame[i]}:"Depth (m)": \
            -C$(echo $cpt) -O -K >> $outfile
         # +ve err
         awk '{if ($1>0) print $1,$2,$3+$4,$5*('${proj[i]}'*4)}' $infile | \
            psxy $area -Jx${proj[i]} -SVT0.1/0.1/0.1n0.5 -O -K -G255/255/255 \
            >> $outfile
         # -ve err
         awk '{if ($1>0) print $1,$2,$3-$4,$5*('${proj[i]}'*4)}' $infile | \
            psxy $area -Jx${proj[i]} -SVT0.1/0.1/0.1n0.5 -O -K -G255/255/255 \
            >> $outfile
         # vector
         awk '{if ($1>0) print $1,$2,$3,$5*('${proj[i]}'*4)}' $infile | \
            psxy $area -Jx${proj[i]} -SVT0.1/0.1/0.1n0.5 -O -G0/0/0 \
            >> $outfile

         echo "done."

         formats $outfile

      done
   done
}

plot
