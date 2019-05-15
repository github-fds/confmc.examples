#
#set terminal x11
#set terminal postscript eps color "Times-Roman"
#set terminal postscript eps "Times-Roman"
#set output "cps.eps"
#set terminal latex roman 10
#set output "cps.tex"

if (!exists('data_file')) data_file='data_float.txt'

set title "FFT"
set xlabel "index"
set ylabel "value"
#set logscale x 2
set xrange [-1:256]
#set xtics (1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024)
#set style line 1 linetype 1 linewidth 5 linecolor "red"   pt 2 pointsize 0.5
#set style line 2 linetype 1 linewidth 5 linecolor "blue"  pt 2 pointsize 0.5
#set style line 3 linetype 1 linewidth 5 linecolor "green" pt 2 pointsize 0.5
set style line 1 linetype 1 linecolor "red"
set style line 2 linetype 1 linecolor "blue"
set style line 3 linetype 1 linecolor "green"

plot data_file using 1 w l title "real",\
     data_file using 2 w l title "image",\
     data_file using (sqrt($1**2+$2**2)) with impulses lw 2 title "sqrt"

pause -1
