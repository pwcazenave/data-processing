#!/bin/bash

# Script to plot the paleaotide constituents from Uehara et al. 2006.

# Which boundary?
boundary=-14.958333
boundaryType=1 # column in file (lat or long)
if [ $boundaryType -eq 1 ]; then
    boundaryTypeAlt=2
else
    boundaryTypeAlt=1
fi

coords=45/65
areaAmp=-R$coords/0.6/1
areaPhase=-R$coords/0/180

proj=-JX15c/6c

yrs=($(seq 0 8))

outfile=./images/palaeo_tidal_constituents.ps

dataDir=/media/z/modelling/data/boundary_files/round_8_palaeo/uehara_boundary/ice-5g/fixed/

#infiles=($dataDir/bte0y-??_0{0..8}0ka.dat $dataDir/bte0y-??_0{0..7}5ka.dat)
infiles=($dataDir/bte0y-??_0{0..8}0ka.dat)

lineStyles=("" "-" "-." "." "")

getConstituent(){
    # Function to pull out the amplitude or phase of the palaeotide
    currFile="$1"
    currType=$2
    awk '{if ($'$boundaryType'=='$boundary') print $'$boundaryTypeAlt',$'$currType'}' $currFile
}

plotAmp(){
    makecpt -T0/${#yrs[@]}/1 -Crainbow > ./cpts/palaeo_tidal_constituents.cpt
    count=0
    for ((i=0; i<${#infiles[@]}; i++)); do
        const=$(echo ${infiles[i]##*/} | cut -f2 -d- | cut -f1 -d_)
        case "$const" in
            "m2")
                style=0
                ;;
            "s2")
                style=1
                ;;
            "k1")
                style=2
                ;;
            "n2")
                style=3
                ;;
            "o1")
                style=4
                ;;
        esac
            
        count=$(echo "scale=0; ($count+1) % ${#yrs[@]}" | bc -l)
        set -x 
        colour=$(awk '{if (NR=='$(($count+5))') printf "%i/%i/%i\n", ($2+$6)/2,($3+$7)/2,($4+$8)/2}' ./cpts/palaeo_tidal_constituents.cpt)
        getConstituent "${infiles[i]}" 3 | \
            psxy $areaAmp $proj -O -K -W5,$colour,${lineStyles[style]} --COLOR_MODEL=+HSV >> $outfile
        set +x
    done
}


psbasemap $areaAmp $proj -Ba2f0.5:,-@+o@+::"Latitude":/a0.2f0.05:"Amplitude (m)":WeSn -K -X2c -Y12c -P > $outfile
plotAmp

psxy -R -J -O -T >> $outfile

formats $outfile
#mv $outfile ./images/ps/
mv ${outfile%.*}.png ./images/png/
