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

trap 'rm *.hod.dat' EXIT

CMD="docker run --rm -v $(pwd):/usr/src/myapp -w /usr/src/myapp mcampbell/sqlite3"
$CMD ruby ./stdev.rb "select hour_of_day, metric_value from bandwidth where metric_type = 'up';"   > up_stdev.hod.dat
$CMD ruby ./stdev.rb "select hour_of_day, metric_value from bandwidth where metric_type = 'down';" > down_stdev.hod.dat

$CMD sqlite3 -column st "select hour_of_day, 10 from bandwidth group by hour_of_day order by 1"    > up_rated.hod.dat
$CMD sqlite3 -column st "select hour_of_day, 50 from bandwidth group by hour_of_day order by 1"    > down_rated.hod.dat

gnuplot hod-up.gnuplot
gnuplot hod-down.gnuplot
