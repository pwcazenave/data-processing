#!/bin/bash

# Script to count the number of raw soundings I've analysed.

prefix1="/media/e/data/"

infiles1=(srtm/badainJaran/raw_data/srtm_57_04-05_utm.xyz.bz2 srtm/simpsonDesert/raw_data/srtm_64_17-18_utm.xyz.bz2 srtm/taklamakanDesert/raw_data/taklamakanDesert_utm.xyz.bz2 aster_gdem/raw_data/aster_gdem_utm_30m.xyz.bz2)

outfile=./raw_data/number_of_points_aeolian.txt

if [ -e $outfile ]; then
    rm -f $outfile
fi

# Check all the files exist.
for ((file=0; file<${#infiles1[@]}; file++)); do
    if [ ! -e "$prefix1/${infiles1[file]}" ]; then 
        echo "$prefix1/${infiles1[file]}" missing
        true
    fi
done

for ((file=0; file<${#infiles2[@]}; file++)); do
    if [ ! -e "$prefix2/${infiles2[file]}" ]; then 
        echo "$prefix2/${infiles2[file]}" missing
        true
    fi
done


# Count the lines depending on extension.
for ((file=0; file<${#infiles1[@]}; file++)); do
    ext=${infiles1[file]##*.}
    echo -n "${infiles1[file]} " >> $outfile
    echo -n "${infiles1[file]}... "
    case $ext in
        "bz2")
            pbzcat "$prefix1/${infiles1[file]}" | wc -l >> $outfile
            ;;
        "xyz")
            wc -l < "$prefix1/${infiles1[file]}" >> $outfile
            ;;
        "txt")
            wc -l < "$prefix1/${infiles1[file]}" >> $outfile
            ;;
        "csv")
            wc -l < "$prefix1/${infiles1[file]}" >> $outfile
            ;;
    esac
    echo "done."
done

for ((file=0; file<${#infiles2[@]}; file++)); do
    ext="${infiles2[file]##*.}"
    echo -n "${infiles2[file]} " >> $outfile
    echo -n "${infiles1[file]}... "
    case $ext in
        "bz2")
            pbzcat "$prefix2/${infiles2[file]}" | wc -l >> $outfile
            ;;
        "xyz")
            wc -l < "$prefix2/${infiles2[file]}" >> $outfile
            ;;
        "txt")
            wc -l < "$prefix2/${infiles2[file]}" >> $outfile
            ;;
        "csv")
            wc -l < "$prefix2/${infiles2[file]}" >> $outfile
            ;;
    esac
    echo "done."
done


awk '{sum+=$2}END{printf "Total raw points:\t%.0f\n", sum}' $outfile
