#!/bin/bash

########################################
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  HERE="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$HERE/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
HERE="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

cd $HERE

trap 'rm *.trend.dat' EXIT

################################################################################
## CHANGEME!  Change the values (10, 50) in the next 2 lines to your rated upload and download speeds in megabits/second
ruby ./trend.rb up   10 < ../data/speedtest.data | tail -100 > ./up_rated.trend.dat
ruby ./trend.rb down 50 < ../data/speedtest.data | tail -100 > ./down_rated.trend.dat
################################################################################
# No changes below this line necessary.
################################################################################


ruby ./trend.rb up    < ../data/speedtest.data | tail -100 > ./up_actual.trend.dat
ruby ./trend.rb down  < ../data/speedtest.data | tail -100 > ./down_actual.trend.dat

up_90_pct=$(sort -k2n ./up_actual.trend.dat | head -10 | tail -1 | awk '{print $2}')
down_90_pct=$(sort -k2n ./down_actual.trend.dat | head -10 | tail -1 | awk '{print $2}')

ruby ./trend.rb up ${up_90_pct}  < ../data/speedtest.data | tail -100 > ./up_90pct.trend.dat
ruby ./trend.rb down ${down_90_pct} < ../data/speedtest.data | tail -100 > ./down_90pct.trend.dat

# (not currently used in any chart)
ruby ../utils/exp_ma.rb -s 10 ./up_actual.trend.dat   > ./up_ma.trend.dat
ruby ../utils/exp_ma.rb -s 10 ./down_actual.trend.dat > ./down_ma.trend.dat

gnuplot ../gnuplot/trend-up.gnuplot 2>/dev/null
gnuplot ../gnuplot/trend-down.gnuplot 2>/dev/null
