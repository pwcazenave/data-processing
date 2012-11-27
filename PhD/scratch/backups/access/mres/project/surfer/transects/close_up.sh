#! /bin/bash

# script to plot several smaller sections of a larger profile

echo -n "Input file: "
read
input="$REPLY"
minmax $input | awk '{print $8 $7}' | tr "<>" "  "
echo -n "w/e/s/n: "
read
space="$REPLY"
echo "Working on $input"
echo $space
awk '{print $4, $3}' $input | psxy -JX15/3 -R$space -Ba50g50/a1g0.5 -P -Xc -Y22 -K > ../subset_plots/$input.ps

gs -sPAPERSIZE=a4 ../subset_plots/$input.ps

exit 0

# set input = raw_data/slope_wreck_002_we.dat && set minmax = -38/-30 && awk '{print $4, $3}' $input | psxy -JX15/3 -R0/400/$minmax -Ba200/a1 -Xc -Y25 -P -K > test.ps && awk '{print $4, $3}' $input | psxy -JX15/3 -R400/800/$minmax -Ba200/a1 -Y-6 -P -O -K >> test.ps && awk '{print $4, $3}' $input | psxy -JX15/3 -R800/1200/$minmax -Ba200/a1 -Y-6 -P -O -K >> test.ps && awk '{print $4, $3}' $input | psxy -JX15/3 -R1200/1400/$minmax -Ba200/a1 -Y-6 -P -O -K >> test.ps && gs -sPAPERSIZE=a4 test.ps


# awk '{print $4, $3}' raw_data/bank_parallel_001.dat | psxy -JX15/3 -R0/400/-34/-31 -Ba200g100/a1g0.5 -Xc -Y25 -P -K > test.ps && awk '{print $4, $3}' raw_data/bank_parallel_001.dat | psxy -JX15/3 -R400/800/-34/-31 -Ba200g100/a1g0.5 -Y-6 -P -O -K >> test.ps && awk '{print $4, $3}' raw_data/bank_parallel_001.dat | psxy -JX15/3 -R800/1200/-34/-31 -Ba200g100/a1g0.5 -Y-6 -P -O -K >> test.ps && gs -sPAPERSIZE=a4 test.ps
