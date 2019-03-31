#!/usr/bin/env bash

########################################
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  HERE="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$HERE/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
HERE="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

cd $HERE

echo Starting at $(date +%Y.%m.%d-%H.%M.%S)
echo Generating hour of day reports
./HOD.sh 

echo Generating hour of week reports
./HOW.sh

echo Generating day of week reports
./DOW.sh

echo Generating trend reports
./TREND.sh
echo Ending at $(date +%Y.%m.%d-%H.%M.%S)
