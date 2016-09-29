# -*- mode:gnuplot -*-
set terminal jpeg small
set timefmt "%Y-%m-%d.%H-%M-%S"
set xdata time
set autoscale
set grid
set xlabel "Time"
set ylabel "Download Mb/sec"

# CHANGEME!!  Set this value to be a bit above your rated DOWNLOAD speed in megabits/second.
set yrange [:70]

set grid
set key box
set output "../images/trend-down.jpg"
plot "down_actual.trend.dat" using 1:2 title "Actual" with lines, \
     "" using 1:2 notitle with points, \
     "down_rated.trend.dat" using 1:2 title "Rated" with lines, \
     "down_90pct.trend.dat" using 1:2 title "90th percentile" with lines

# optional
# , "down_ma.trend.dat"    using 1:2 title "Moving Average" with lines
