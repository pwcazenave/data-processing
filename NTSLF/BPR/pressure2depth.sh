#!/bin/bash

# Use the hydrostatic pressure to calculate an equivalent depth. Add nonsense
# residual and quality flags too (as per SHOM approach).

files=(./raw_data/*.dat ./raw_data/*.lst)

for ((i=0; i<${#files[@]}; i++)); do
    # Convert mbar -> bar -> Pa, then calcualte depth from hydrostatic
    #   P = rho*g*z
    # Assuming  rho = 1026kg/m3
    #           g = 9.81 m/s2
    #           P = pressure in Pascals
    #           z = depth in metres
    if [ ${files[i]##*.} == 'lst' ]; then
        header=20
    else
        header=13
    fi
    echo -n "${files[i]}: $header "
    if grep -qi pressure ${files[i]}; then
        echo "pressure"
        awk '{if (NR>'$header') print $2,$3,(($4/1000)*1e5)/(1026*9.81)}' ${files[i]} | \
            tr "/" " " | tr ":" "." | awk -F. '{OFS=","}{print $1,$2,$3"."$4,"-9999","P"}' | \
            tr " " "," > ./formatted/$(basename ${files[i]})
    else
        echo "elevation"
        # We don't have pressure (must have surface elevation). These records
        # don't have a site depth, so just extract the surface elevation
        # timeseries.
        awk '{if (NR>'$header') print $2,$3,$4}' ${files[i]} | \
            tr "/" " " | tr ":" "." | awk -F. '{OFS=","}{print $1,$2,$3"."$4,"-9999","P"}' | \
            tr " " "," > ./formatted/$(basename ${files[i]})
    fi
done
