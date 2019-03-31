# -*- mode:gnuplot -*-
set terminal jpeg small
set timefmt "%Y-%m-%d.%H-%M-%S"
set xdata time
set autoscale
set grid
set xlabel "Time"
set ylabel "Upload Mb/sec"

# CHANGEME!!  Set this value to be a bit above your rated UPLOAD speed in megabits/second.
set yrange [:20]

set grid
set key box
set output "../images/trend-up.jpg"
plot "up_actual.trend.dat" using 1:2 title "Actual" with lines, \
     "" using 1:2 notitle with points, \
     "up_rated.trend.dat" using 1:2 title "Rated" with lines, \
     "up_90pct.trend.dat" using 1:2 title "90th percentile" with lines

