#!/bin/bash

#  Script to plot the tracklines. Each channel (post/starboard) will be a
#+ different colour, and all points will be plotted but with no reference to
#+ depth value.

set -e

all="false"
minmax="false"
image="false"
input="false"
output="false"

proj=-Jx0.01

gmtset ANNOT_FONT_SIZE 10
gmtset LABEL_FONT_SIZE 12
gmtset HEADER_FONT_SIZE 14
gmtset ANNOT_FONT_SIZE_SECONDARY 10
gmtset D_FORMAT %7.9lg

if [ $# -eq 0 ]; then
   do_all
fi

while test -n "$1"; do
   case "$1" in
      --all|-a)
         all="true"
         shift
         ;;
      --minmax|-m)
         input="true"
         output="true"
         minmax="true"
         shift
         ;;
      --image|-i)
         input="true"
         output="true"
         shift
         ;;
      --help|-h)
         usage
         shift
         exit 1
         ;;
      *)
         echo "Unknown argument: $1"
         usage
         exit 1
         ;;
   esac
done

do_input() {
echo -n "Input file name: "
read "file"
if [[ -z $file ]]; then
   echo "Error: Please specify an input file name"
   exit 1
else
   infile="$file"
fi

do_output() {
echo -n "Output file name: "
read "file"
if [[ -z $file ]]; then
   echo "Error: Please specify an output file name"
   exit 1
else
   outfile=./images/"$file".ps
fi
}

do_minmax() {
   \rm -f ./.minmax
   echo -n "calculating minmax... "
   minmax -I2/2/2/2 "$infile" > ./.minmax
   echo "done."
   area=$(< ./.minmax)
}

do_imaging() {
   echo -n "imaging... "
   psbasemap $area $proj \
      -Ba200f100:"Eastings":/a200f100:"Northings"::."$infile":WeSn \
      -Xc -Yc -K > "$outfile"
   psscale -D22/5.5/5/0.5 -B2 -I-1/1 -C.hwtma.cpt -O -K >> "$outfile"
   for i in $(ls $input)
      if [ "$i" == "*port*" ]; then
         psxy $area $proj -Sp -G255/0/0 -O -K >> $outfile
      elif [ "$i" == "*stbd*" ]; then
         psxy $area $proj -Sp -G0/255/0 -O -K >> $outfile
      fi

   echo -n "conversion... "
   ps2pdf -r1200 -sPAPERSIZE=a4 "$outfile" \
      "./images/`basename "$outfile" .ps`.pdf"
   gs -sDEVICE=jpeg -r1200 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE \
      "-sOutputFile=./images/`basename "$outfile" .ps`.jpg" \
      "$outfile" > /dev/null
   echo "done."
}

if [ "$all" == "true" ]; then
   do_input
   do_output
   do_minmax
   do_imaging
fi
if [ "$input" == "true" ]; then
   do_input
fi
if [ "$output" == "true" ]; then
   do_output
fi
if [ "$minmax" == "true" ]; then
   do_minmax
fi
if [ "$image" == "true" ]; then
   do_image
fi
