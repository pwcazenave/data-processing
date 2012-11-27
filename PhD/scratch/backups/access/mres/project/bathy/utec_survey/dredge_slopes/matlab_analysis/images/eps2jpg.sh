#!/bin/bash

# script to convert the .eps output from matlab to jpegs

for file in *.eps; do
   gs -sDEVICE=jpeg -dNOPAUSE -dBATCH -r300 -sOutputFile=${file%.eps}.jpg \
      $file
done
