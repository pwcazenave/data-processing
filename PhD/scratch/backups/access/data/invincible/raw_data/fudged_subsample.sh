#!/bin/bash

# because of the extraordinarily large number of points in the mca data,
# the corresponding script has to split the file in a number of subsections,
# each roughly 1GB in size (arbitrarily). then need to use awk to work on each
# of those subsections, writing only values that fall within a particular
# range to a new output file.

INFILES=./invincible_bathy_raw.txt
OUTFILE=./subset.xyz

if [ -e $OUTFILE ]; then
   echo -n "Output file already exists. Overwrite? [y/n]: "
   read ANSWER
   if [ $ANSWER == "y" ]; then
      \rm -f $OUTFILE
      touch $OUTFILE
      for MASSIVE in $INFILES; do
         echo -n "Working on $MASSIVE... "
#         split $MASSIVE -l 10000000 | \
         awk '{
            if ($1>638395 && $1<638405 && $2>5622695 && $2<5622705)
            print $1,$2,$5
         }' $MASSIVE >> $OUTFILE
         echo "done."
      done
   else
      echo "Abort. Cannot write to output file."
      exit 1
   fi
else
   touch $OUTFILE
   for MASSIVE in $INFILES; do
#      split $MASSIVE -l 10000000 - | \
      echo -n "Working on $MASSIVE... "
      awk '{
         if ($1>638395 && $1<638405 && $2>5622695 && $2<5622705)
         print $1,$2,$5
      }' $MASSIVE >> $OUTFILE
      echo "done."
   done
fi

exit 0
