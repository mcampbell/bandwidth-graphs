#!/bin/bash

# speedtest-cli comes from https://github.com/sivel/speedtest-cli

set -eu

########################################
FORCE=""
TRANSIENT=""
PING_HOST="google.com"
while getopts "hftp:" opt; do
  case $opt in
    h) echo "usage -o option1" ;;
    f) FORCE="-f"          ;;
    t) TRANSIENT="-t"      ;;
    p) PING_HOST="$OPTARG" ;;
    *) echo "invalid argument"; exit -1 ;;
  esac
done
shift $((OPTIND - 1))

########################################
HERE="$(cd "$(dirname "$0")" && pwd -P)"
THISBIN="$(basename $0)"

cd "$HERE"


########################################
# Error checking

if ! which sqlite3 &>/dev/null; then
  echo sqlite3 binary not found.  Exiting.
  exit 1
fi

DB="${HERE}/st"

if [ ! -r "$DB" ]; then
  cat ./create.sql | sqlite3 "$DB"
fi


touch $HERE/lastrun-epoch.txt
TOO_OLD=""
NOW=$(date +%s)
LASTRUN=$(cat $HERE/lastrun-epoch.txt)
if [ -z "$LASTRUN" ]; then
  DELTA="1000000" # something big
  echo "$LASTRUN" > $HERE/lastrun-epoch.txt
  TOO_OLD="too-old"
else
  DELTA=$(( NOW - LASTRUN ))
  if [ "$DELTA" -ge 3600 ]; then  # run at least once an hour.
    TOO_OLD="too-old"
  fi
fi



# Run this a couple/few times an hour, but at random times.  We do this check every minute.
if [ -n "$FORCE" ]; then
  echo $(date) - ${DELTA} - FORCE was set.  Running. >> $HOME/logs/speedtest.sh.log
  echo "$NOW" > $HERE/lastrun-epoch.txt

elif [ -n "$TOO_OLD" ]; then  
  echo $(date) - ${DELTA} - Last run was $DELTA seconds ago.  Running. >> $HOME/logs/speedtest.sh.log
  echo "$NOW" > $HERE/lastrun-epoch.txt

else 
  CHANCE=$(( RANDOM % 600 ))
  if [ "$CHANCE" -ge 10 ]; then  # 15 times / 600 mins; => ~1.5 times/hour
    echo $(date) - ${DELTA} - Chance was $CHANCE.  Not running. >> $HOME/logs/speedtest.sh.log
    exit 0
  else
    if [ "$DELTA" -lt 600 ]; then # but not more recently than 10 mins.
      echo $(date) - ${DELTA} - Chance was $CHANCE but just ran.  Not running. >> $HOME/logs/speedtest.sh.log
      exit 0
    else
      echo $(date) - ${DELTA} - Chance was $CHANCE.  Running. >> $HOME/logs/speedtest.sh.log
      echo "$NOW" > $HERE/lastrun-epoch.txt
    fi
  fi
fi


T=/tmp/speedtest.$$

trap "rm $T" EXIT

if [ -x ./utils/context.sh ]; then
  CTX="$(echo "$*" | tr [:upper:] [:lower:] | tr -cs [a-z0-9] - | sed -e 's/-$//')@$(./utils/context.sh)"

else
  CTX=""     
fi   

# convert -0400 to -04:00
Z=$(date +%z)
ZONE="$(echo "$Z" | sed -e 's/..$//'):$(echo "$Z" | sed -e 's/^...//')"
DATE="$(date '+%Y-%m-%d %H:%M:%S')${ZONE}"

DOW=$(( $(date +%w) + 0 ))
HOD=$(( $(date +%H) + 0 ))
HOW=$(( $(( $DOW * 24 )) + $HOD ))

# First do a connectivity check.  Set everything to 0 if it fails.

if ping -c1 "$PING_HOST" 2>&1 | grep --silent ' 0% packet loss'; then
  $HERE/speedtest-cli --simple > $T
  DOWN=$(grep 'Download:' $T | cut -f2 -d: | awk '{print $1}')
  UP=$(grep 'Upload:' $T | cut -f2 -d: | awk '{print $1}')
  PING=$(grep 'Ping:' $T | cut -f2 -d: | awk '{print $1}')

else
  DOWN=0.0
  UP=0.0
  PING=9999.0
fi


# Date, day-of-week, hour-of-day, hour-of-week, direction, metric, context
echo "$DATE,$DOW,$HOD,$HOW,up,${UP},$CTX"
echo "$DATE,$DOW,$HOD,$HOW,down,${DOWN},$CTX"
echo "$DATE,$DOW,$HOD,$HOW,ping,${PING},$CTX"

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
