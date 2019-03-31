#!/bin/bash

########################################
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  HERE="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$HERE/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
HERE="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

set -e

cd $HERE

DB="$HERE/../data/st"

trap 'rm *.hod.dat' EXIT

ruby ../utils/stdev.rb "$DB" "select hour_of_day, metric_value from bandwidth where metric_type = 'up';"   > ./up_stdev.hod.dat
ruby ../utils/stdev.rb "$DB" "select hour_of_day, metric_value from bandwidth where metric_type = 'down';" > ./down_stdev.hod.dat

################################################################################
## CHANGEME!  Change these values (10, 50) to whatever your rated upload and download speeds are (in megabits/second)
sqlite3 -column "$DB" "select hour_of_day, 15 from bandwidth group by hour_of_day order by 1"    > ./up_rated.hod.dat
sqlite3 -column "$DB" "select hour_of_day, 75 from bandwidth group by hour_of_day order by 1"    > ./down_rated.hod.dat
################################################################################
# No changes below this line necessary.
################################################################################

gnuplot ../gnuplot/hod-up.gnuplot 2>/dev/null
gnuplot ../gnuplot/hod-down.gnuplot 2>/dev/null
