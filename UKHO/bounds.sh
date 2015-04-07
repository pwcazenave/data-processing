#/bin/bash

# Script to get the bound box for each ascii data set.

parallel gmt gmtinfo -C {} \> metadata/{/.}.bnd ::: ascii/*.ascii
