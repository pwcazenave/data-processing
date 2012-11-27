#!/bin/bash

# script to resample grid files to a different resolution. will do both 
# illumination and bathy grid

# dredge
# bathy first, methinks. 2m resample from whatever (must be higher res though)
grdsample -I1 ./dredge_final.grd -Gdredge_final_resampled_1m.grd

# then the gradient, same res
grdsample -I1 ./dredge_grad.grd -Gdredge_grad_resampled_1m.grd

# 3d dunes
grdsample -I1 ./3d_dunes_final.grd -G3d_dunes_final_resampled_1m.grd

# then the gradient, same res
grdsample -I1 ./3d_dunes_grad.grd -G3d_dunes_grad_resampled_1m.grd

