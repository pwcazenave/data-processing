#!/bin/bash

# x and y == $2 and $6
# pass a directory as the argument

set -e

if [ "$1" == "" ]; then
   echo "Please supply a directory."
   echo "$(basename $0) DIR"
   exit 1
elif [ ! -d "$1" ]; then
   echo "Directory supplied does not exist."
   exit 1
else
   echo "outputting results to $1".
   for file in "$1"/*x_transport.txt; do
      echo -n "working on "${file%x_transport.txt}dir_mag.txt"... "
      paste "$file" "${file%x_transport.txt}y_transport.txt" | \
         awk '{
            if ($2>0 && $6>0) {
               printf "%1.6f %2.6f %3.6f %1.10f\n", $3,$4,(atan2($2,$6))*(180/3.141592654),sqrt($2^2+$6^2)
            } else if ($2>0 && $6<0) {
               printf "%1.6f %2.6f %3.6f %1.10f\n", $3,$4,(atan2($2,$6))*(180/3.141592654),sqrt($2^2+$6^2)
            } else if ($2<0 && $6<0) {
               printf "%1.6f %2.6f %3.6f %1.10f\n", $3,$4,360+((atan2($2,$6))*(180/3.141592654)),sqrt($2^2+$6^2)
            } else if ($2<0 && $6>0) {
               printf "%1.6f %2.6f %3.6f %1.10f\n", $3,$4,360+((atan2($2,$6))*(180/3.141592654)),sqrt($2^2+$6^2)
            }
         }' > "${file%x_transport.txt}dir_mag.txt"
         echo "done."
   done
   echo "Finished."
fi
