#!/bin/bash

########################################
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  HERE="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$HERE/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
HERE="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

cd "$HERE"

DB="$HERE/../data/st"

trap 'rm *.dow.dat' EXIT

ruby ../utils/stdev.rb "$DB" "select day_of_week, metric_value from bandwidth where metric_type = 'up';"   > ./up_stdev.dow.dat
ruby ../utils/stdev.rb "$DB" "select day_of_week, metric_value from bandwidth where metric_type = 'down';" > ./down_stdev.dow.dat

## CHANGEME!  Change these values (10, 50) to whatever your rated upload and download speeds are (in megabits/second)
sqlite3 -column "$DB" "select day_of_week, 10 from bandwidth group by day_of_week order by 1"    > ./up_rated.dow.dat
sqlite3 -column "$DB" "select day_of_week, 50 from bandwidth group by day_of_week order by 1"    > ./down_rated.dow.dat
################################################################################
# No changes below this line necessary.
################################################################################

gnuplot ../gnuplot/dow-up.gnuplot 2>/dev/null
gnuplot ../gnuplot/dow-down.gnuplot 2>/dev/null
