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

trap 'rm *.dow.dat' EXIT

CMD="docker run --rm -v $(pwd):/usr/src/myapp -w /usr/src/myapp mcampbell/sqlite3"
$CMD ruby ./stdev.rb "select day_of_week, metric_value from bandwidth where metric_type = 'up';"   > up_stdev.dow.dat
$CMD ruby ./stdev.rb "select day_of_week, metric_value from bandwidth where metric_type = 'down';" > down_stdev.dow.dat

$CMD sqlite3 -column st "select day_of_week, 10 from bandwidth group by day_of_week order by 1"    > up_rated.dow.dat
$CMD sqlite3 -column st "select day_of_week, 50 from bandwidth group by day_of_week order by 1"    > down_rated.dow.dat

gnuplot ./dow-up.gnuplot
gnuplot ./dow-down.gnuplot
