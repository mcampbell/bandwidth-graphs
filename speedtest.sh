#!/bin/bash

# speedtest-cli comes from https://github.com/sivel/speedtest-cli

set -eu

echo Starting at $(date)

########################################
HERE="$(cd "$(dirname "$0")" && pwd -P)"
THISBIN="$(basename $0)"

########################################
TRANSIENT=""
PING_HOST="google.com"
while getopts "hftp:" opt; do
  case "$opt" in
    h)
      echo "usage ${THISBIN} [-(t)ransient] [-(p)ing_host host]"
      echo "     transient: if set, will not write to database.          Default: off/false"
      echo "     ping_host: the host to ping to determine connectivity.  Default: google.com"
      ;;
    t) TRANSIENT="-t"      ;;
    p) PING_HOST="$OPTARG" ;;
    *) echo "invalid argument"; exit -1 ;;
  esac
done
shift $((OPTIND - 1))


cd "$HERE"


########################################
# Error checking

function check_exe() {
  local exe="$1"

  if ! which "$exe" &> /dev/null; then
    echo The "$exe" binary was not found, and is required.  Exiting.
    exit 3
  fi
}

export PATH=.:$HOME/bin:$PATH
check_exe sqlite3
check_exe gnuplot
check_exe speedtest-cli

########################################
DB="${HERE}/data/st"

if [ ! -r "$DB" ]; then
  cat ./utils/create.sql | sqlite3 "$DB"
fi


T="/tmp/speedtest.$$"

function cleanup() {
  rm "$T" 2>/dev/null
  echo Ending at $(date)
  echo '--'
}

trap cleanup EXIT

########################################
# Set up context
if [ -x ./utils/context.sh ]; then
  CTX="$(./utils/context.sh "$*")"

else
  CTX=""     
fi   

########################################
# Current date/time
# convert -0400 to -04:00
Z=$(date +%z)
ZONE="$(echo "$Z" | sed -e 's/..$//'):$(echo "$Z" | sed -e 's/^...//')"
DATE="$(date '+%Y-%m-%d %H:%M:%S')${ZONE}"

DOW=$(( $(date +%w | sed -e 's/^0//') + 0 ))
HOD=$(( $(date +%H | sed -e 's/^0//') + 0 ))
HOW=$(( $(( DOW * 24 )) + HOD ))

# First do a connectivity check.  Set everything to 0 if it fails.

if ping -c1 "$PING_HOST" &>/dev/null; then
  speedtest-cli --simple > $T
  DOWN=$(grep 'Download:' $T | cut -f2 -d: | awk '{print $1}')
  UP=$(grep 'Upload:' $T | cut -f2 -d: | awk '{print $1}')
  PING=$(grep 'Ping:' $T | cut -f2 -d: | awk '{print $1}')

else
  DOWN=0.0
  UP=0.0
  PING=9999.0
fi


# Date, day-of-week, hour-of-day, hour-of-week, direction, metric, context
echo "$DATE,$DOW,$HOD,$HOW,up,${UP},$CTX"      | tee -a "$HERE"/data/speedtest.data
echo "$DATE,$DOW,$HOD,$HOW,down,${DOWN},$CTX"  | tee -a "$HERE"/data/speedtest.data
echo "$DATE,$DOW,$HOD,$HOW,ping,${PING},$CTX"  | tee -a "$HERE"/data/speedtest.data

# create table bandwidth (
#   test_time    TEXT,
#   day_of_week  INTEGER,
#   hour_of_day  INTEGER,
#   hour_of_week INTEGER,
#   metric_type  TEXT,
#   metric_value REAL,
#   context      TEXT);


# if not transient, save the data.
if [ -z "$TRANSIENT" ]; then  
  echo "insert into bandwidth values('$DATE', $DOW, $HOD, $HOW, 'up', $UP, '$CTX');"       | sqlite3 "$DB"
  echo "insert into bandwidth values('$DATE', $DOW, $HOD, $HOW, 'down', ${DOWN}, '$CTX');" | sqlite3 "$DB"
  echo "insert into bandwidth values('$DATE', $DOW, $HOD, $HOW, 'ping', $PING, '$CTX');"   | sqlite3 "$DB"
fi
