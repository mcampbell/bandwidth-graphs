set terminal jpeg
set grid
set autoscale
set xlabel "Day of Week"
set ylabel "Upload Mb/sec"
set xrange [-1:7]
set yrange [:15]
set key box
set output "dow-up.jpg"
plot "up_stdev.dow.dat" title "Actual" with errorbars, "up_rated.dow.dat" title "Rated" with lines
