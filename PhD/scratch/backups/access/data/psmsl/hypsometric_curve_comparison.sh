#!/bin/bash

# script to plot hypsometric curves of all the bathy data sets, and plot the
# psmsl data on top. could be messy.

etopoin=../etopo/raw_data/bathy_clipped.txt
gebcoin=../gebco/plot/raw_data/gebco_channel.xyz
cmapin=../cmap/raw_data/corrected_CMAP_bathy.xyz
seazonein=../seazone/Bathy/gridded_bathy/bathy.xyz # do awk check
britnedin=../britned/raw_data/BritNed_bathy_modeledited.dat # not in lat/longs

harea=-R-110/20/0/100
proj=-JX23/14

sources=($gebcoin $etopoin $cmapin $seazonein $britnedin)
outfile=(
   ./images/hypsometric/gebco_hypsometric_hist.ps
   ./images/hypsometric/etopo_hypsometric_hist.ps
   ./images/hypsometric/cmap_hypsometric_hist.ps
   ./images/hypsometric/seazone_hypsometric_hist.ps
   ./images/hypsometric/britned_hypsometric_hist.ps
   )
names=(GEBCO ETOPO2 C-MAP SeaZone BritNed)

# try sorting the depths and plotting using psxy
plot(){
   for ((i=0; i<${#sources[@]}; i++)); do
      echo -n "working on ${sources[i]}... "
      size=$(grep '[0-9]' ${sources[i]} | wc -l | cut -f1 -d" ")
      seq $size > /tmp/ysize$i
      area=-R-110/0/0/$(($size+1000))
      awk '{print $3}' ${sources[i]} | grep '[0-9]' | \
         sort -g > /tmp/xdata$i
         paste -d" " /tmp/xdata$i /tmp/ysize$i > /tmp/plot_file$i
         awk '{print $1,$2}' /tmp/plot_file$i | \
         psxy $area $proj -Ba20f5g20:,-m::Depth:/a100000f25000g100000:Frequency\ count:WeSn -K -Xc -Yc > ${outfile[i]}
      echo "done."
   done
   \rm /tmp/ysize
}

plot_hists(){
   for ((i=0; i<${#sources[@]}; i++)); do
      echo -n "working on ${sources[i]}... "
      pshistogram $harea $proj -W0.25 -G100/100/100 -L1/0/0/0 -T2 -Z1 -Q \
         -Xc -Yc ${sources[i]} \
         -Ba20f5g20:Depth\ \(m\):/a10f2g10:,-%:WeSn \
         > ${outfile[i]}
      echo "done."
   done
}

formats(){
   # convert the images
   for ((i=0; i<${#outfile[@]}; i++)); do
      echo -n "converting to pdf "
      ps2pdf -sPAPERSIZE=a4 -dPDFSETTINGS=/prepress "${outfile[i]}" \
         ${outfile[i]%.ps}.pdf
      echo -n "and jpeg... "
      gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE \
         "-sOutputFile=${outfile[i]%.ps}.jpg" \
         "${outfile[i]}" > /dev/null
      echo "done."
   done
}


#plot - far too slow, and didn't work properly for all data anyway...
plot_hists
formats

exit 0
