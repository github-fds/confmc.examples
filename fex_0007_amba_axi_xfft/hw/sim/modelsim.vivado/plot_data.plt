#
#set terminal x11
#set terminal postscript eps color "Times-Roman"
#set terminal postscript eps "Times-Roman"
#set output "cps.eps"
#set terminal latex roman 10
#set output "cps.tex"

if (!exists('data_file')) data_file='data_float.txt'

set title "Signal"
set xlabel "time"
set ylabel "value"
#set logscale x 2
set xrange [-1:256]
#set xtics (1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024)
set style line 1 linetype 2 linewidth 2 linecolor "red"  pt 1 pointsize 0.5
set style line 2 linetype 2 linewidth 2 linecolor "blue" pt 1 pointsize 0.5
#set pointsize 1.5
#set size 1.0,1.0
#set datafile commentschars "#!%"
#N = system("awk 'NR==2{print NF}' data_float.txt")
#plot for [i=1:N] data_file using 0:i w l title "real"

plot data_file using 1 with linespoints title "real"

pause -1
