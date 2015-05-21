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
    root="http://nomads.ncdc.noaa.gov/data/cfsr"
    for m in ${months[@]}; do
        ym=$(printf %04d%02d $y $m)
        dir=$(printf %04d/%04d%02d $y $ym)
        cd $dir

        echo -en "\rWorking on $(printf %04d/%02d:\  $y $m)"
        # Grab the relevant types:
        #
        # - pressfc - surface pressure
        # - prate - precipitation rate
        # - tmp2m - 2m temperature
        # - dlwsfc - downward long wave radiation at surface
        # - uswsfc - upward short wave radiation at surface
        # - dswsfc - downward short wave radiation at surface
        # - lhtfl - latent heat flux (for evaporation)
        # - q2m - specific humidity (can convert to relative)
        # - wnd10m - u and v wind (packed together)
        echo -n "fetching: "
        for v in pressfc prate tmp2m dlwsfc uswsfc dswsfc q2m wnd10m; do
            echo -n "$v "
            file=$(printf %s.gdas.%04d%02d.grb2 $v $y $m)
            url=$(printf %s/%04d%02d/%s $root $y $m $file)

            wget \
                --quiet \
                "$url" \
                -c
        done
        # Convert those files to netCDF, extracting only the forecast data,
        # leaving the analysis data behind.
        # Do pressfc separately as it has weird issues with its grid.
        echo -n "converting... "

        # Ditch the "0-0 day ave fcst" outputs and keep only the "0-? hour ave
        # fcst". We'll have to do some postprocessing to reconstruct the hourly
        # averages following this approach:
        #
        #   X = N*a - (N-1)*b
        #
        # where X is the hourly average of interest at hour N. a and b are 0-N
        # and 0-(N-1). For example, for the average between hours 3 and 4 from
        # 0, use the 4 hour average (0-4) as a and the three hour average (0-3)
        # as b:
        #
        #   X = 4*a - 3*b

        # Instantaneous data:
        parallel wgrib2 {} \
            -netcdf {.}.nc \
            -match "\":(.+*:.+*:. hour fcst):\"" \> /dev/null \
            ::: {pressfc,tmp2m,q2m,wnd10m}.gdas.${ym}.grb2 \
        # Hourly averaged data:
        parallel wgrib2 {} \
            -netcdf {.}.nc \
            -match "\":(.+*:surface:0-[1-9] hour ave fcst):\"" \
            \> /dev/null \
            ::: {prate,dlwsfc,uswsfc,dswsfc}.gdas.${ym}.grb2

        # Append the variables into a single file.
        mv pressfc.gdas.${ym}.nc cfs.gdas.${ym}.nc
        for v in prate tmp2m dlwsfc uswsfc dswsfc q2m wnd10m; do
            ncks -A ${v}.gdas.${ym}.nc cfs.gdas.${ym}.nc
        done
        # Remove intermediate netCDF files.
        rm {prate,tmp2m,dlwsfc,uswsfc,dswsfc,q2m,wnd10m}.gdas.${ym}.nc

        # Archive the raw .grb2 files for future deletion.
        if [[ ! -d archives ]]; then
            mkdir archives
        fi
        mv *.grb2 archives

        echo "done."
        cd ~-
    done
done
