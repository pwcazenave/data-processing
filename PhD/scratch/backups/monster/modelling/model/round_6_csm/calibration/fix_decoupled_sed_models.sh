#!/bin/bash

# use the original default model files as the basis for modification
Mval=45
group=25

#for i in *d.m21fm; do
for i in ${@}; do
   cp $i ${i%.*}_vanRijn_equilib_0_4mm.m21fm

   # enable sand transport
   sed -i 's|mode_of_sand_transport_module = 0|mode_of_sand_transport_module = 2|g' ${i%.*}_vanRijn_equilib_0_4mm.m21fm

   # find the relevant line (SAND_TRANSPORT_MODULE), then change the line after it
   sed -i -n '1h;1!H;${;g;s|\[SAND_TRANSPORT_MODULE\]\n      mode = 0\n      \[EQUATION\]|\[SAND_TRANSPORT_MODULE\]\n      mode = 2\n      \[EQUATION\]|g;p;}' ${i%.*}_vanRijn_equilib_0_4mm.m21fm

   # fix bed load formulae
   sed -i 's|bed_load_formula = 1|bed_load_formula = 2|;s|suspended_load_formula = 1|suspended_load_formula = 2|g' ${i%.*}_vanRijn_equilib_0_4mm.m21fm

   # fix output paths
   sed -i 's|..\\..\\..\\..\\results\\round_6_csm\\uk_csm_v4.1_M=20_calib\\calibgroup25|G:\\modelling\\results\\round_6_csm\\uk_csm_v4.1_M=45_calib\\decoupled\\calibgroup25_M=45|g' ${i%.*}_vanRijn_equilib_0_4mm.m21fm

   # change from non-equilibrium to equilibrium
   sed -i 's|transport_description = 1|transport_description = 0|g' ${i%.*}_vanRijn_equilib_0_4mm.m21fm

   # change grain diameter
   sed -i 's|grain_diameter = 0.2|grain_diameter = 0.4|g' ${i%.*}_vanRijn_equilib_0_4mm.m21fm
done
