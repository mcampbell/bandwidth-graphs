set terminal jpeg
set grid
set autoscale
set xlabel "Day of Week"
set ylabel "Upload Mb/sec"
set xrange [-1:7]

# CHANGEME!!  Set this value to be a bit above your rated UPLOAD speed in megabits/second.
set yrange [:20]

set key box
set output "../images/dow-up.jpg"
plot "up_stdev.dow.dat" title "Actual" with errorbars, "up_rated.dow.dat" title "Rated" with lines
