#!/bin/bash

# reformat the data for vectors for the fortran code
for file in ./2007-07/vectors/*.txt; do
   outdir=./2007-07/vectors/fortran_input/
   name=$(grep Day: $file | awk '{print $4"_"$2}')
   awk 'FNR>10{if ($5<255) print $1, $2, $3, $4}' $file | \
      sed -e :a -e '$d;N;2,23ba' -e 'P;D' \
      > $outdir/$name.dat
done

