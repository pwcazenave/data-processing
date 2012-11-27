#!/bin/bash
#
# Script to run the mike models.
# Takes n models as arguments, and runs them in sequence.
#

PATH=/cygdrive/c/Program\ Files/DHI/MIKEZero/bin:$PATH
MIKE=/cygdrive/c/Program\ Files/DHI/MIKEZero/bin

MODELS=${*}

for CURRENT in $MODELS; do
   cd ${CURRENT%/*}
   MzLaunch -exit ${CURRENT##*/}
   cd -
done

exit 0
