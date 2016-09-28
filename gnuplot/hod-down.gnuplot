set terminal jpeg
set grid
set xlabel "Hour of Day"
set ylabel "Download Mb/sec"
set xrange [-1:]
set yrange [:70]
set key box
set output "hod-down.jpg"
plot "down_stdev.hod.dat" title "Actual" with errorbars, "down_rated.hod.dat" title "Rated" with lines
