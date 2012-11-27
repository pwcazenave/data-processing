#!/bin/bash

# use the original default model files as the basis for modification

for i in *d.m21fm; do
   cp $i ${i%.*}_vanRijn_equilib_0_4mm.m21fm
   # fix bed load formulae
   sed -i 's|bed_load_formula = 1|bed_load_formula = 2|;s|suspended_load_formula = 1|suspended_load_formula = 2|g' ${i%.*}_vanRijn_equilib_0_4mm.m21fm
   # fix output paths
   sed -i 's|..\\..\\..\\..\\..\\results\\round_6_csm\\uk_csm_v4.1_M=40_calib\\decoupled\\calibgroup1_M=|G:\\modelling\\results\\round_6_csm\\uk_csm_v4.1_M=40_calib\\decoupled\\calibgroup1_M=|g' ${i%.*}_vanRijn_equilib_0_4mm.m21fm
   # change from non-equilibrium to equilibrium
   sed -i 's|transport_description = 1|transport_description = 0|g' ${i%.*}_vanRijn_equilib_0_4mm.m21fm
   # change grain diameter
   sed -i 's|grain_diameter = 1|grain_diameter = 0.4|g' ${i%.*}_vanRijn_equilib_0_4mm.m21fm
done
