#!/bin/csh -f

# script to run all the different files needed to get a final image from this directory

\echo "***"
\echo "Change to the raw data directory, and apply the depth shift"
\echo "***"

\cd ./raw_data/emu
./depth_shift.sh

\echo "***"
\echo "Change back to the top-level directory and execute the script to create the grids"
\echo "***"
\cd ../..
./bathy.sh

\echo "***"
\echo "Move the grids to the grids directory"
\echo "***"
\mv emu_* ./grids/emu/
\mv cco_* ./grids/cco/

\echo "***"
\echo "Change into the grids directory and execute the script to plot the final images"
\echo "***"
\cd ./grids
./plot.sh

\echo "***"
\echo "Done!"
\echo "Current dir is $PWD"
