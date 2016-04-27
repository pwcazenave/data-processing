Download both .lst and .qxf files.

Script order to add new data:
0. Create a metadata file (all_sites.csv) by catting the BODC metadata files. Remove the header (23 lines) first:

for i in *; do
    unzip $i bodc_series_metadata_summary.csv
    tail -n +24 bodc_series_metadata_summary.csv > ../${i%.*}.csv
    rm bodc_series_metadata_summary.csv
done

1. Reformat the old files to have YYYYMMDD formatted dates rather than DDMMYY:

# Pre-2000

for i in RN-1382_1375269533891.csv; do
    awk -F\/ '{print $1"/"$2"/19"$3"/"$4"/19"$5"/"$6}' $i | sed 's/\/$//g' > ${i%.*}_new.csv
    mv ${i%.*}_new.csv $i
done

# Post-2000
for i in RN-6033_1372326062972.csv RN-7029_1372240803092.csv RN-8553_1372331108255.csv; do
    awk -F\/ '{print $1"/"$2"/"$3"/20"$4"/"$5"/20"$6}' $i | sed 's/\/\/20$//g' > ${i%.*}_new.csv
    mv ${i%.*}_new.csv $i
done

1. get_full_times.sh
2. add_full_times.sh
