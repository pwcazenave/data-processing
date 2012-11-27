#!/bin/csh -f

# script to apply the depth corrections to the emu single beam bathy

# set the shift values
set bea = 2.44
set chi = 2.74
set cow = 2.59
set ham = 2.74
set hay = 2.74
set lan = 2.74 # haven't got a real value for this - using the same one as chichester
set new = 1.83
set wcw = 2.59
set yar = 1.83

# set the inputs
set bea_input = ./original/bea*
set chi_input = ./original/chi*
set cow_input = ./original/cow*
set ham_input = ./original/ham*
set hay_input = ./original/hay*
set lan_input = ./original/lan*
set new_input = ./original/new*
set wcw_input = ./original/wes*
set yar_input = ./original/yar*

# set the outputs
set bea_output = ./corrected_to_od/beaulieu.xyz
set chi_output = ./corrected_to_od/chichester.xyz
set cow_output = ./corrected_to_od/cowes.xyz
set ham_output = ./corrected_to_od/hamble.xyz
set hay_output = ./corrected_to_od/hayling.xyz
set lan_output = ./corrected_to_od/langstone.xyz
set new_output = ./corrected_to_od/newtown.xyz
set wcw_output = ./corrected_to_od/west_cowes.xyz
set yar_output = ./corrected_to_od/yarmouth.xyz

# apply the correction
awk '{if ($3<0) print $1,$2,($3-'$bea'); else print $1, $2, $3}' $bea_input > $bea_output
awk '{if ($3<0) print $1,$2,($3-'$chi'); else print $1, $2, $3}' $chi_input > $chi_output
awk '{if ($3<0) print $1,$2,($3-'$cow'); else print $1, $2, $3}' $cow_input > $cow_output
awk '{if ($3<0) print $1,$2,($3-'$ham'); else print $1, $2, $3}' $ham_input > $ham_output
awk '{if ($3<0) print $1,$2,($3-'$hay'); else print $1, $2, $3}' $hay_input > $hay_output
awk '{if ($3<0) print $1,$2,($3-'$lan'); else print $1, $2, $3}' $lan_input > $lan_output
awk '{if ($3<0) print $1,$2,($3-'$new'); else print $1, $2, $3}' $new_input > $new_output
awk '{if ($3<0) print $1,$2,($3-'$wcw'); else print $1, $2, $3}' $wcw_input > $wcw_output
awk '{if ($3<0) print $1,$2,($3-'$yar'); else print $1, $2, $3}' $yar_input > $yar_output

