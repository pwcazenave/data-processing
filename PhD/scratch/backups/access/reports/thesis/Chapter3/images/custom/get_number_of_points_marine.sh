#!/bin/bash

# Script to count the number of raw soundings I've analysed.

prefix1="/media/e/data/"
prefix2="/media/g/data/"

infiles1=(./aggregates/area481/raw_data/7878_Area481_2m_Jan2009_UTMZone31_cut.xyz.bz2 ./aggregates/culver_sands/2009/Processed\ Data/Swathe/raw_data/2009_latlong.xyz ./britned/raw_data/britned_bathy.csv ./mca/bathy/raw_data/ws_1m_blockmean.txt.bz2 ./seazone/SouthernNorthSea/raw_data/sns_utm31n_25m.xyz ./ukho/bathy/tarbat_ness_sarclet_head/processed/raw_data/tarbatNess-SarcletHead_1m_ne.txt.bz2 ./ukho/bathy/tarbat_ness_sarclet_head/processed/raw_data/tarbatNess-SarcletHead_1m_nw.txt.bz2 ./ukho/bathy/tarbat_ness_sarclet_head/processed/raw_data/tarbatNess-SarcletHead_1m_se.txt.bz2 ./ukho/bathy/tarbat_ness_sarclet_head/processed/raw_data/tarbatNess-SarcletHead_1m_sw.txt.bz2 ./ukho/bathy/wee_bankie_gourdon/processed/raw_data/weeBankie-Gourdon_utm_2m.txt.bz2 ./mca/hi1059/raw_data/hi1059_b_ll.xyz)
infiles2=(./jibs/raw_data/jibs_1m.xyz.bz2)

outfile=./raw_data/number_of_points_marine.txt

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
