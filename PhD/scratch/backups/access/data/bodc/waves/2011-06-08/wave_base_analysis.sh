#!/bin/bash

# Script to calculate two wave peneration values based on Soulsby's (1997)
# formulae from significant wave height and average wave period:
#
#   h < 0.1gTp      (1)
#
# and
#
#   h < 10Hs        (2)
#
# indicate shallow water waves, where h is water depth, g is the acceleration
# due to gravity, Tp is the wave period and Hs is the significant wave height.
#
# Depths are taken from the model mesh (combo_v2.mesh) rather than the
# buoy metadata since I'm interested in the effect in the model.
#
# This script uses the wave period as the input (i.e. Equation 1).
#
# Input data NaN value is -1 (for both height and period).
#
# Pierre Cazenave 2011-06-08 v1.0
#

# Vamos!
#

set -eu

wavePenetration(){
    # Calculate the wave penetration depth and compare with the observed
    # depth extracted from the model mesh.

    inDepths=/media/z/modelling/data/waves/round_8_palaeo/bodc/extracted_depths.csv
    dos2unix -q $inDepths
    if [ ! -d ./selected/analysed/ ]; then
        mkdir ./selected/analysed
    fi
    for file in $(cut -f4 -d, $inDepths); do
        modelDepth=$(grep $file $inDepths | cut -f3 -d,)

        # Add two new columns (based on height and period), where 1 is for shallow
        # waves (i.e. penetration is greater than depth), otherwise 0.
        accGrav=9.81 # acceleration due to gravity
        tr -d "KNPQR" < ./selected/formatted/$file.lst | \
            awk 'function abs(x){return (((x < 0.0) ? -x : x) + 0.0)}
            function waveBaseH(x){return (10*x) + 0.0}
            function waveBaseT(x){return (0.1*'$accGrav'*x^2) + 0.0}
            {
                if (waveBaseH($3)>abs('$modelDepth') && $3>0)
                    print $1,$2,$3,$4,"1";
                else if (waveBaseH($3)<abs('$modelDepth') && $3>0)
                    print $1,$2,$3,$4,"0";
                else if ($3<=0)
                    print $1,$2,$3,$4,"NaN"
            }' \
                > ./selected/analysed/$file.lst
    done
}

percentageTime(){
    # Analyse the results from wavePenetration to determine the percentage of
    # time for which the bed felt the waves.
    rm -f ./selected/wave_base_penetration_timing.csv
    for file in ./selected/analysed/*.lst; do
        totalLengthNoNAN=$(grep -v NaN $file | wc -l)
        totalLengthDeep=$(awk '{if ($5==0) print $0}' $file | wc -l)
        totalLengthShallow=$(awk '{if ($5==1) print $0}' $file | wc -l)
        percentageDeep=$(echo "($totalLengthDeep/$totalLengthNoNAN)*100" | bc -l)
        percentageShallow=$(echo "($totalLengthShallow/$totalLengthNoNAN)*100" | bc -l)
        baseData=($(grep $(basename ${file%.*}) ./wave_locations_uniques.csv))
        echo "${baseData[@]},$percentageDeep,$percentageShallow" >> ./selected/wave_base_penetration_timing.csv
    done
}

wavePenetration
percentageTime

