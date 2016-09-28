set terminal jpeg
set grid
set autoscale
set xlabel "Hour of Week"
set ylabel "Download Mb/sec"
set xrange [-1:]
set yrange [:70]
set key box
set output "how-down.jpg"
plot "down_stdev.how.dat" title "Actual" with errorbars, "down_rated.how.dat" title "Rated" with lines
