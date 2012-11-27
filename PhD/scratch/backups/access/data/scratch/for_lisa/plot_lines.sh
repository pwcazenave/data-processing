#!/bin/bash

# script to quickly plot the track lines for the seismic lines off Pakistan

area=-R61.5/66.1/23/25.1
proj=-Jm5

awk '{print $2,$6}' ./pwg98_ph1_simple.txt | \
   psxy $area $proj -W5/0/50/200 -M -H1 -Ba1f0.25g0.5WeSn -Xc -Yc > ./lines.ps
