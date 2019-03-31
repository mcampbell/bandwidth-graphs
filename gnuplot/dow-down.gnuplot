set terminal jpeg
set grid
set autoscale
set xlabel "Day of Week"
set ylabel "Download Mb/sec"
set xrange [-1:7]

# CHANGEME!!  Set this value to be a bit above your rated DOWNLOAD speed in megabits/second.
set yrange [:100]

set key box
set output "../images/dow-down.jpg"
plot "down_stdev.dow.dat" title "Actual" with errorbars, "down_rated.dow.dat" title "Rated" with lines
