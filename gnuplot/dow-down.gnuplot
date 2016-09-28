set terminal jpeg
set grid
set autoscale
set xlabel "Day of Week"
set ylabel "Download Mb/sec"
set xrange [-1:7]
set yrange [:70]
set key box
set output "dow-down.jpg"
plot "down_stdev.dow.dat" title "Actual" with errorbars, "down_rated.dow.dat" title "Rated" with lines
