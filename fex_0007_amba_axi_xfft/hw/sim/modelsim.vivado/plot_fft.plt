#
#set terminal x11
#set terminal postscript eps color "Times-Roman"
#set terminal postscript eps "Times-Roman"
#set output "cps.eps"
#set terminal latex roman 10
#set output "cps.tex"

if (!exists('data_file')) data_file='data_float.txt'

set title "FFT"
#set xlabel "index"
unset xlabel
set ylabel "value"
set xrange [-1:256]

set multiplot layout 3, 1
set tmargin 2

unset key
set title "FFT Real"
plot data_file using 1 w l

unset key
set title "FFT Image"
plot data_file using 2 w l

unset key
set title "FFT Sqrt"
plot data_file using (sqrt($1**2+$2**2)) with impulses lw 2

unset multiplot

pause -1
