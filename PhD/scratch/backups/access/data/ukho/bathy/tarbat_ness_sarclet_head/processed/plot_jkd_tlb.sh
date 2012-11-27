#!/bin/bash

# Script to plot the blockmeaned Tarbat Ness to Sarclet Head bathy.
#

area=-R447809/541820/6408563/6472555
area=-R440000/545000/6407000/6475000
proj=-Jx0.0002
gres=20

infile=./raw_data/jkd_tlb_20m_weighted_out_parallel_negative.txt
outfile=./images/$(basename ${infile%.*}.ps)

cpt=./cpts/tarbatNess-SarcletHead.cpt
grd=./grids/tarbatNess-SarcletHead_${gres}m.grd
grad=${grd%.*}_grad.grd

gmtset COLOR_NAN=black

formats(){
    if [ $# -eq 0 ]
    then
        echo "Converts PostScript to pdf and png."
        echo "Error: not enough inputs."
        echo "Usage: formats file1.ps [file2.ps] ... [filen.ps]"
    fi
    for i in "$@"
    do
        echo -n "converting $i to pdf "
        ps2pdf -sPAPERSIZE=a4 -dAutoRotatePages=/PageByPage -dPDFSETTINGS=/prepress -q "$i" "${i%.*}.pdf"
        echo -n "and png... "
        gs -sDEVICE=png16m -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE -q -sOutputFile="${i%.ps}.png" "$i"
        echo "done."
    done
}

#xyz2grd $area -I$gres $infile -G$grd
makecpt -T-82/0/0.5 -Z > $cpt
grdgradient -Ne0.7 -E45/70 $grd -G$grad
grdimage $area $proj -B25000WeSn -C$cpt $grd -I$grad -Xc -Yc -K > $outfile
psscale -D10/-2/10/0.5h -I -B10 -C$cpt -O >> $outfile

formats $outfile
