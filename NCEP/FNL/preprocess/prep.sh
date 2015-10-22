#!/usr/bin/env bash

# Do all the preprocessing needed for each of the years for which I want to run
# WRF.

set -eu

# For metgrid.exe to run in parallel.
module load mpi/mpich-x86_64
np=$(grep -c physical\ id /proc/cpuinfo)
if [ -z $np ]; then
    np=1
fi

namelist=templates/namelist.wps
Vtable=templates/Vtable
years=({2002..2004})
years=(2003)
grids=(grids/geo_em.d??.nc)

if [ ! -d ./logs ]; then
    mkdir ./logs
fi

for year in ${years[@]}; do
    if [ ! -d ./$year ]; then
        mkdir ./$year
    fi

    (
        cd $year

        # Link to the model grids.
        for grid in ${grids[@]}; do
            if [ ! -h $(basename $grid) ]; then
                ln -s ../$grid
            fi
        done

        # Put the Vtable in the current directory.
        if [ -h Vtable ]; then
            rm -f Vtable
        fi
        if [ ! -f ./Vtable ]; then
            ln -s ../$Vtable
        else
            echo "WARNING: Vtable found but not a symlink to the default one."
        fi

        # Don't clobber old namelists.
        if [ -f namelist.wps ]; then
            mv namelist.wps namelist.wps.$$
        fi
        cp ../$namelist namelist.wps

        sed -i 's/2002-'/$year-'/g' namelist.wps

        # Run the link script, ungrib and then finally metgrid.
        ../bin/link_grib.csh ../../$year/*.grib1
        ../bin/ungrib.exe 2>&1 ../logs/${year}_ungrib.log
        mpirun -n $np ../bin/metgrid.exe 2>&1 ../logs/${year}_metgrid.log

        # Tidy up
        rm Vtable namelist.wps GRIBFILE.???
        for grid in ${grids[@]}; do
            rm $(basename $grid)
        done
    )
done


