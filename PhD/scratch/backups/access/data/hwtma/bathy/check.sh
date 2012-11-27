#!/bin/bash

# script to plot the difference in angle values against the angle

area=-R0/45/0/6
proj=-JX21/13

# 10cm
psxy ./raw_data/difference_precision_10cm.dat $area $proj -K -X3 -Yc \
   -Ba5f2.5g5:"Angle (@+o@+)":/a1f0.5g1:"Angle Difference (@+o@+)":WeSn \
   -W3/0/200/100 > ./images/check.ps
psxy ./raw_data/difference_precision_10cm.dat $area $proj -O -K \
   -Sc0.1 -B0 -W3/0/200/100 >> ./images/check.ps

# 25cm
psxy ./raw_data/difference_precision_25cm.dat $area $proj -O -K \
   -B0 -W3/0/0/0 >> ./images/check.ps
psxy ./raw_data/difference_precision_25cm.dat $area $proj -O -K \
   -Sc0.1 -B0 -W3/0/0/0 >> ./images/check.ps

# 50cm
psxy ./raw_data/difference_precision_50cm.dat $area $proj -O -K \
   -B0 -W3/0/100/200 >> ./images/check.ps
psxy ./raw_data/difference_precision_50cm.dat $area $proj -O -K \
   -Sc0.1 -B0 -W3/0/100/200 >> ./images/check.ps

# 1m
psxy ./raw_data/difference_precision_1m.dat $area $proj -O -K \
   -B0 -W3/200/0/100 >> ./images/check.ps
psxy ./raw_data/difference_precision_1m.dat $area $proj -O -K \
   -Sc0.1 -B0 -W3/200/0/100 >> ./images/check.ps

# 2.5m
psxy ./raw_data/difference_precision_2.5m.dat $area $proj -O -K \
   -B0 -W3/255/165/0 >> ./images/check.ps
psxy ./raw_data/difference_precision_2.5m.dat $area $proj -O -K \
   -Sc0.05 -B0 -W3/255/165/0 >> ./images/check.ps

# 5m
psxy ./raw_data/difference_precision_5m.dat $area $proj -O -K \
   -B0 -W3/100/100/100 >> ./images/check.ps
psxy ./raw_data/difference_precision_5m.dat $area $proj -O -K \
   -Sc0.05 -B0 -W3/100/100/100 >> ./images/check.ps

# add in the text labels
pstext -N $area $proj -O -K << TEXT >> ./images/check.ps
47.5 4.5 10 0 0 1 Grid Spacing
50 3.9 10 0 0 1 10cm
50 3.4 10 0 0 1 25cm
50 2.9 10 0 0 1 50cm
50 2.4 10 0 0 1 1m
50 1.9 10 0 0 1 2.5m
50 1.4 10 0 0 1 5m
TEXT

t_area=-R0/30/0/23
t_proj=-JX30c/23c

psbasemap $t_area $t_proj -X-3.1 -Y-5 -B0 -O -K >> ./images/check.ps

# add in the lines
psxy -O -K -B0 $t_area $t_proj -W3/0/200/100 << ten >> ./images/check.ps
25 13.5
26 13.5
ten
psxy -O -K -B0 $t_area $t_proj -W3/0/200/100 -Sc0.1 << symbol >> ./images/check.ps
25.5 13.5
symbol
psxy -O -K -B0 $t_area $t_proj -W3/0/0/0 << twentyfive >> ./images/check.ps
25 12.5
26 12.5
twentyfive
psxy -O -K -B0 $t_area $t_proj -W3/0/0/0 -Sc0.1 << symbol >> ./images/check.ps
25.5 12.5
symbol
psxy -O -K -B0 $t_area $t_proj -W3/0/100/200 << fifty >> ./images/check.ps
25 11.42
26 11.42
fifty
psxy -O -K -B0 $t_area $t_proj -W3/0/100/200 -Sc0.1 << symbol >> ./images/check.ps
25.5 11.42
symbol
psxy -O -K -B0 $t_area $t_proj -W3/200/0/100 << one >> ./images/check.ps
25 10.3
26 10.3
one
psxy -O -K -B0 $t_area $t_proj -W3/200/0/100 -Sc0.1 << symbol >> ./images/check.ps
25.5 10.3
symbol
psxy -O -K -B0 $t_area $t_proj -W3/255/165/0 << twoandahalf >> ./images/check.ps
25 9.2
26 9.2
twoandahalf
psxy -O -K -B0 $t_area $t_proj -W3/255/165/0 -Sc0.1 << symbol >> ./images/check.ps
25.5 9.2
symbol
psxy -O -K -B0 $t_area $t_proj -W3/100/100/100 << five >> ./images/check.ps
25 8.1
26 8.1
five
psxy -O -K -B0 $t_area $t_proj -W3/100/100/100 -Sc0.1 << symbol >> ./images/check.ps
25.5 8.1
symbol

gs -sDEVICE=jpeg -r600 -dNOPAUSE -dBATCH -sPAPERSIZE=a4 -sOutputFile=./images/check.jpg ./images/check.ps >/dev/null
ps2pdf -sPAPERSIZE=a4 ./images/check.ps ./images/check.pdf
gs -sDEVICE=x11 ./images/check.ps

exit 0
