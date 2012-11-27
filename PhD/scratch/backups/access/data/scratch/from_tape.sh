#!/bin/bash

# script to take the tarred data off the tape, run md5sum on all the files,
# and then delete the directory, get the next tar archive off and so on.

for tar in $HOME/scratch/tmp/tape/*; do
   tar xvf /dev/nst0
   find $tar -type f -exec md5sum {} \; \
      > ./md5sums/"$(basename $tar)".md5
   find /tmp/pwc101/noc -type f -exec md5sum {} \; \
      > ./md5sums/"$(basename $tar)"_tape.md5
   awk '{print $1}' ./md5sums/"$(basename $tar)"_tape.md5 | sort \
      > ./md5sums/"$(basename $tar)"_got_1.md5
   awk '{print $1}' ./md5sums/"$(basename $tar)".md5 | sort \
      > ./md5sums/"$(basename $tar)"_origs_2.md5
   paste ./md5sums/"$(basename $tar)"_got_1.md5 \
      ./md5sums/"$(basename $tar)"_origs_2.md5 \
      > ./md5sums/"$(basename $tar)"_compare.md5
#   \rm ./md5sums/"$(basename $tar)"_got_1.md5 ./md5sums/"$(basename $tar)"_origs_2.md5
   \rm -r ./noc
done
