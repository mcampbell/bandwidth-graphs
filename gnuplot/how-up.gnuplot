set terminal jpeg
set grid
set autoscale
set xlabel "Hour of Week"
set ylabel "Upload Mb/sec"
set xrange [-1:]
set yrange [:15]
set key box
set output "how-up.jpg"
plot "up_stdev.how.dat" title "Actual" with errorbars, "up_rated.how.dat" title "Rated" with lines
