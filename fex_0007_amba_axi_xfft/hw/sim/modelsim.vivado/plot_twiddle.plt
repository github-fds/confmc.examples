#
set terminal x11
#set terminal postscript eps color "Times-Roman"
#set terminal postscript eps "Times-Roman"
#set output "cps.eps"
#set terminal latex roman 10
#set output "cps.tex"

if (!exists('data_file')) data_file='twiddle_table.txt'

set title "FFT twiddle"
set xlabel "index"
set ylabel "value"
#set logscale x 2
set xrange [-1:128]
#set xtics (1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024)
set style line 1 linetype 2 linewidth 2 linecolor "red"  pt 1 pointsize 0.5
set style line 2 linetype 2 linewidth 2 linecolor "blue" pt 1 pointsize 0.5
#set pointsize 1.5
#set size 1.0,1.0
#set datafile commentschars "#!%"

plot data_file using 1 ls 1 title "real",\
     data_file using 2 ls 2 title "image"

pause -1
