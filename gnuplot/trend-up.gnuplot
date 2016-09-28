# -*- mode:gnuplot -*-
set terminal jpeg small
set timefmt "%Y-%m-%d.%H-%M-%S"
set xdata time
set autoscale
set grid
set xlabel "Time"
set ylabel "Upload Mb/sec"
set yrange [:15]   # our upper limit of ~12Mb + some room for stdev
set grid
set key box
set output "trend-up.jpg"
plot "up_actual.trend.dat" using 1:2 title "Actual" with lines, \
     "" using 1:2 notitle with points, \
     "up_rated.trend.dat" using 1:2 title "Rated" with lines, \
     "up_90pct.trend.dat" using 1:2 title "90th percentile" with lines

