#!/bin/bash
#
# Script to cut a gridded domain into smaller sections specified on the
# command line. Files are output to ./cut/<grid_basename>/<subset_size>
# Cut size can be rectangular and angled.
#
#
# Copyright 2010 Pierre Cazenave <pwc101 {at} soton [dot] ac (dot) uk>
# All rights reserved.
#
# Redistribution and use of this script, with or without modification, is
# permitted provided that the following conditions are met:
#
# 1. Redistributions of this script must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR ''AS IS'' AND ANY EXPRESS OR IMPLIED
# WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
# EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

set -eu

if [ $# -ne 6 ]; then
    echo "$(basename $0): <subset_size> <angle> <direction> <x_offset> <y_offset> <grid_file>"
    exit 1
fi

gmtdefaults -D > ./.gmtdefaults4

incX=$(echo $1 | cut -f1 -d\/)
incY=$(echo $1 | cut -f2 -d\/)
if [ -z $incY ]; then
    $incY=$incX
fi
angle="$2"
direction="$3"
offsetX="$4"
offsetY="$5"
ingrd="$6"
prefix=$(basename "${ingrd%.*}")

area=$(grdinfo -I1 "$ingrd")

if [ ! -d ./cut/${1/\//-}/$prefix ]; then
    mkdir -p ./cut/${1/\//-}/$prefix
fi

cleanup(){
    for file in "$@"; do
        if [ -e "$file" ]; then
            \rm -f "$file"
        fi
    done
}

cutgrid(){
    pysplit $area -I$incX/$incY -D$direction -A$angle -X$offsetX -Y$offsetY | \
    while read line; do
    	outgrd=./cut/${1/\//-}/$prefix/${prefix}_$(echo "$line" | tr " " "_" | sed 's/\.0//g').grd
        grdcut $ingrd $(echo "-R$line" | tr " " "/") -G$outgrd || true
		# Remove any grid files with non values in them
		mm=($(grdinfo -C $outgrd | awk '{print $6,$7}'))
		if [ ${mm[0]} == 0 -a ${mm[1]} == 0 ]; then 
			rm $outgrd
			echo "Removed grid file with no valid values."
		fi
    done
    cleanup ./.gmt*
    echo "Done."
}

cutgrid "$1"

exit 0
