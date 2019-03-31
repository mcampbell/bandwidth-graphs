set terminal jpeg
set grid
set autoscale
set xlabel "Hour of Day"
set ylabel "Upload Mb/sec"
set xrange [-1:24]

# CHANGEME!!  Set this value to be a bit above your rated UPLOAD speed in megabits/second.
set yrange [:20]

set key box
set output "../images/hod-up.jpg"
plot "up_stdev.hod.dat" title "Actual" with errorbars, "up_rated.hod.dat" title "Rated" with lines
