#!/bin/bash

# Extract only the nav points with unique fixes.

infile=./HastingsBoomerNavENs.txt

prev=$(head -2 $infile | grep -v [a-z] | awk '{print $5-1}')

grep -v [a-z] $infile \
   | while read line; do
      fix=$(echo $line | cut -f5 -d' ')
      diff=$(($fix-$prev))
      if [ $diff -ne 0 ]; then
         echo $line >> ${infile%.*}_thinned.txt
      fi
      prev=$(echo $line | cut -f5 -d' ')
   done #< $infile
