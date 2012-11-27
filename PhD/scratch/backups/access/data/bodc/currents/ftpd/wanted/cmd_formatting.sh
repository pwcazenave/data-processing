#!/bin/bash

# clear all previous versions
echo -n "prepping the directory... "
\rm ./site_locations.lst ./site_names.lst ./doc_locations.txt 2>/dev/null
echo "done."

# do the cmd dir - not very accurate
echo "working on: ./cmd... "

# get the coordinates and format accordingly
echo -n "find and format coordinates... "
touch ./site_locations.lst
for i in ./f*.lst; do
   tmp1=$(grep mN $i | \
   awk '{print $1}' | tr "mdN" " " | \
   awk '{print $1+($2/10), $3+($4/10), $5}' | \
   awk '{if ($3 == "W") print $1, ($2*-1); else print $1, $2}')

   tmp2=$(grep Series $i | awk '{print $2}')
   echo $tmp1 $tmp2 >> ./site_locations.lst
done
echo "done."

echo -n "extracting those in the region of interest... "
echo "LatDD, LongDD, Site_No" > subset.txt
awk '{if (($2 > -2) && ($1 > 49) && ($1 < 52.5)) print $1", "$2", "$3}' \
   site_locations.lst >> subset.txt
echo "done."

# get the station ids and produce a single file with these in
#echo -n "find station names... "
#touch ./site_names.lst
#for i in ./cmd/*.lst; do
#   grep Id $i | sed 's/Id://'\
#   awk '{print $1}' | \
#   >> ./site_names.lst
#done
#echo "done."

# paste the two files together into a 3 column file
#echo -n "make a single file... "
#echo "LatDD	LongDD	ID" > ./sites.txt
#paste ./site_locations.lst ./site_names.lst >> ./sites.txt
#echo "done."

#echo -n "clean up"
#\rm ./site_names.lst ./site_locations.lst 2>/dev/null
#echo "done."

#echo "now working on ./documentation... "

#echo -n "precleaning directory..."
#\rm ./doc_locations.lst ./doc_names.lst 2> /dev/null
#echo "done."

#echo -n "extract the coordinates from the nightmareish html files... "
# ok, this is messy, but it seems to work...
#for i in ./documentation/*.htm; do
#   tr "<" "\n" < $i | \
#   grep -A2 tude | grep deg | sed 's/td>//' | \
#   awk '{print $1, $2}' | tr "\n" " " | \
#   awk '{print $1, $3, $4}' | \
#   awk '{if ($3 == "W") print $1, ($2*-1); else print $1, $2}' \
#   >> ./doc_locations.lst
#done
#echo "done."

#echo -n "and get the corresponding site identifiers... "
#for i in ./documentation/*.htm; do
#   tr "<" "\n" < $i | \
#   grep -A2 Originator\'s\ Identifier | sed 's/td>//' | \
#   tail -n 1 | grep / >> ./doc_names.lst
#done
#echo "done."

#echo -n "make a single file... "
#echo "LatDD	LongDD	ID" > ./doc_sites.txt
#paste ./doc_locations.lst ./doc_names.lst >> ./doc_sites.txt
#echo "done."

exit 0
