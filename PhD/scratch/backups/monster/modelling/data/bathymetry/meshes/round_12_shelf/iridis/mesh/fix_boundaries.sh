#!/bin/bash

# Since the mesh merge tool doesn't preserve arc attribute values
# properly, this script should reinstate them for a given set of
# coordinates. Will only work for rectangular domains, however. 

west1=-14.958   # 5
east1=-8        # 0
west2=-8        # 0
east2=2         # 0
west3=2         # 0
east3=15.042    # 3
south=44.958    # 4
north=64.968    # 2

infile=${infile:-./uniform_v4_west-middle-east.mesh}

set -eu

if [ ! -e $infile ]; then
    echo "Input missing ($infile). Aborting."
    exit 1
fi

# This is the overly complicated way:
#awk '{
#    if (NF==5 && $2=='$west1')
#        print $1,$2,$3,$4,"5";
#    else if (NF==5 && $2=='$east1')
#        print $1,$2,$3,$4,"0";
#    else if (NF==5 && $2=='$west2')
#        print $1,$2,$3,$4,"0";
#    else if (NF==5 && $2=='$east2')
#        print $1,$2,$3,$4,"0";
#    else if (NF==5 && $2=='$west3')
#        print $1,$2,$3,$4,"0";
#    else if (NF==5 && $2=='$east3')
#        print $1,$2,$3,$4,"3";
#    else if (NF==5 && $3=='$south')
#        print $1,$2,$3,$4,"4";
#    else if (NF==5 && $3=='$north')
#        print $1,$2,$3,$4,"2";
#    else
#        print $0;
#    }' \
#    $infile > ${infile%.*}_fixed.mesh

# This is the easy way:
awk '{
    if (NF==5 && $5>5)
        print $1,$2,$3,$4,"0";
    else
        print $0;
    }' \
    $infile > ${infile%.*}_fixed.mesh



        
