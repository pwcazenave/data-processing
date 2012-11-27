#! /bin/csh -f
#
# grid GMT script
#
set area = -R-300/300/-150/150
blockmean $area -I1/1 xyzlist | surface $area -I1/1 -Gmagnetics.grd
