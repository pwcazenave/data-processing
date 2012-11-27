rm fig4.ps

psbasemap -R0.0/90.0/0.0/400.0 -Jx0.2/0.03 -Ba20f10:"Half-Spreading Rate (mm/yr)":/a100f20:"Root-mean-square Roughness (m)":WSne -X4.0 -Y-8.0 -K -V > fig4.ps

psxy goff.dat -M -R -Jx -Sc0.3 -Ey -G255 -W2 -K -O -V >> fig4.ps

psxy malin.dat -R0.0/180.0/0.0/400.0 -Jx0.1/0.03 -Sc0.3 -Ey -G0 -W2 -K -O -V >> fig4.ps

psxy rough2.dat -R -Jx -Sc0.15 -W2 -G0 -K -O -V >> fig4.ps

psxy rough_new.dat -R -Jx -St0.3 -W2 -G0 -K -O -V >> fig4.ps

pstext -R -Jx -V -O << END >> fig4.ps
34.0 139.0 18 0.0 1 1 A
14.0 165.0 18 0.0 1 1 B
34.0 112.0 18 0.0 1 1 C
14.0 145.0 18 0.0 1 1 D
14.0 329.0 18 0.0 1 1 E
14.0 357.0 18 0.0 1 1 F
END

gs fig4.ps &
