#!/bin/bash

for i in *dir*2.txt; do 
   echo longDD latDD dir transport > ../${i//dir/dir_mag}
   paste $i ${i//dir/mag} | \
   awk '{printf "%.6f %.6f %.6f %.10f\n", $3,$4,$2,$6}' >> ../${i//dir/dir_mag}
done
