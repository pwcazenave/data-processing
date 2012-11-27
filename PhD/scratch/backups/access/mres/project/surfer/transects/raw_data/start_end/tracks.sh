#!/bin/bash
#
# script to 
#

gmtset D_FORMAT %.2f

for start_end in ./*.bln; do
   CROPPED=$(sed '1d' $start_end)
   start=$(sed '1d' $start_end | head -n1 | sed 's/,\ /\//')
   end=$(tail -n1 $start_end | sed 's/,\ /\//')
   project -C$start -E$end -G0.25 -N > ./tracks/${start_end%.bln}.dat
done
exit 0
