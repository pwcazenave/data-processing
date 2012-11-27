#!/bin/bash

# Extract the node and elements sections of a specified mesh file.

set -eu

mesh="$1"

if [ -f ./nodes.txt -o -f ./elements.txt ]; then
    rm ./nodes.txt ./elements.txt
fi
if [ -f ${mesh%.*}_elements.txt -o -f ${mesh%.*}_nodes.txt ]; then
    rm ${mesh%.*}_nodes.txt ${mesh%.*}_elements.txt
fi

# We'll use the number of fields as our guide
awk '{
    if (NF==2 && NR==1)
        print $0 > "./nodes.txt"
    else if (NF==5)
        print $0 >> "./nodes.txt"
    else if (NF==3 && NR!=1)
        print $0 > "./elements.txt"
    else if (NF==4)
        print $0 >> "./elements.txt"
    }' $mesh

mv ./nodes.txt ${mesh%.*}_nodes.txt
mv ./elements.txt ${mesh%.*}_elements.txt
