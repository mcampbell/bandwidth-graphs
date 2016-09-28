set terminal jpeg
set grid
set autoscale
set xlabel "Hour of Day"
set ylabel "Upload Mb/sec"
set xrange [-1:]
set yrange [:15]
set key box
set output "hod-up.jpg"
plot "up_stdev.hod.dat" title "Actual" with errorbars, "up_rated.hod.dat" title "Rated" with lines
