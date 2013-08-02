#!/bin/bash

# Run as:
#
# $ ./get_port_erin_identifiers.sh | sort -u

# Unique variable names from the netCDF files.
vars=('FNTOTWCTX' 'CPHLFLP3' 'FNTRAZZXX' 'FAMONAAZX' 'SSALBSTX' 'NTRZAAZX' 'FACYCAA01' 'SLCAAAZX' 'AADYAA01' 'TEMPPR01' 'FOXYSZZ01' 'FDOXYWITX' 'FPHOSZZXX' 'NTRIAAZX' 'FAAFDZZ01' 'FSLCAAAZX' 'FCPHLFLP3' 'FNTRZAAZX' 'AAFDZZ01' 'DOXYWITX' 'NTRAZZXX' 'AMONAAZX' 'FNTRIAAZX' 'PHOSZZXX' 'FSSALBSTX' 'OXYSZZ01' 'FTEMPPR01' 'ACYCAA01' 'NTOTWCTX' 'ADEPZZ01' 'FTPHSPP01' 'PHOSMAZX' 'NTOTZZXX' 'FPHOSMAZX' 'FNTOTZZXX' 'CDTAZZ01' 'TPHSPP01' 'PSALBSTX' 'FCDTAZZ01' 'FPSALBSTX' 'DOXYZZXX' 'FDOXYZZXX' 'SSALAGT1' 'FSSALAGT1')

for file in $(find ./raw_data/ -mtime -10 -type f -iname "*.lst"); do
    for ((i=0; i<${#vars[@]}; i++)); do
        res=$(grep -hA1 ^${vars[i]} $file | tail -1)
        if [ ! -z "$res" ]; then
            echo "defs['${vars[i]}'] = '$res'"
        fi
    done
done
