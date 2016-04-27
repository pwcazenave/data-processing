#/bin/bash

set -u

# Fetch the CFSv2 data from the time series archive on the NOAA HTTP server.
# Use the pressure level data rather than the ocean data as the former covers
# land whilst the latter is (obviously) water only. Fortunately, the pressure
# level data has surface and Xm levels too, so I can extract data from sensible
# heights for use in forcing FVCOM.

# Range of years for which to download data.
years=({1990..2000})
years=(1990)
months=({1..12})

for y in ${years[@]}; do
    root="http://nomads.ncdc.noaa.gov/modeldata/cmd_pgbh"
    for m in ${months[@]}; do
        days=$(date -d "$y/$m/01 + 1 month - 1 day" +%d)
        for d in $(seq 1 $days); do
            c=0
            for h in 00 06 12 18; do
                dir=$(printf %04d/%04d%02d/%04d%02d%02d $y $y $m $y $m $d)
                mkdir -p $dir

                # Grab all the files. The instructions
                # (http://nomads.ncdc.noaa.gov/docs/CFSRR-KnownDataIssues.pdf)
                # give a method for reconstructing the hourly averages from the
                # relevant files, but it's Friday afternoon and I can't get my
                # head around it, so I'll just grab everything and think about
                # it later.
                for r in {00..06} 09 nl; do
                    # Some indication of progress. Should be 36 per day.
                    c=$((c+1))
                    pc=$(echo "scale=2; ((($c)/36)*100)" | bc -l)
                    echo -en "\rWorking on $(printf %04d/%02d/%02d:\ fetching\ %02.0f%% $y $m $d $pc)"
                    file=$(printf pgbh%s.gdas.%04d%02d%02d%02d.grb2 $r $y $m $d $h)
                    url=$(printf %s/%s/%s $root $dir $file)

                    cd $dir
                    wget \
                        --quiet \
                        "$url" \
                        -c
                    wget -c --quiet "$url".md5
                    #md5sum --quiet -c ${file}.md5
                    #ret=$?
                    ##rm ${file}.md5
                    cd ~-

                    #if [ $ret -ne 0 ]; then
                    #    echo $dir/$file > corrupted.txt
                    #fi
                done
                # Do the md5 checks in parallel.
                #cd $dir
                #parallel md5sum --quiet -c {} ::: *.md5
                #cd ~-
            done
            # Extract the variables we're interested in with wgrib2. Don't do
            # the nl files as I don't know what they are. They're also missing
            # lots of the surface variables.
            echo -n " converting... "
            parallel wgrib2 {} \
                -netcdf {.}.nc \
                -nc4 \
                -match "\":\(UGRD:10 m above ground|VGRD:10 m above ground|TMP:surface|DSWRF:surface|USWRF:surface|DLWRF:surface|TMP:2 m above ground|PRES:surface|LHTFL:surface|RH:2 m above ground|APCP:surface\):\"" \
                \> /dev/null \
                ::: $dir/pgbh{00..06}.gdas.??????????.grb2
            echo "done."
        done
    done
done
