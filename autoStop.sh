#!/bin/bash

set -e

threshold=0.1
count=0
wait_minutes=10


pseudopid="`pgrep -f $0 -l`"
actualpid="$(echo "$pseudopid" | grep -v 'sudo' | awk -F ' ' '{print $1}')"

if [[ `echo $actualpid` != "$$" ]]; then
    echo "Another instance of shell already exist! Exiting"
    exit
fi

while true
do

  load=$(uptime | sed -e 's/.*load average: //g' | awk '{ print $1 }') # 1-minute average load
  load="${load//,}" # remove trailing comma
  res=$(echo $load'<'$threshold | bc -l)
  if (( $res ))
  then
    echo "Idling.."
    ((count+=1))
  else
    count=0
  fi
  echo "Idle minutes count = $count"

  if (( count>wait_minutes ))
  then
    echo Shutting down
    # wait a little bit more before actually pulling the plug
    sudo poweroff
  fi

  sleep 60

done
