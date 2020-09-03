#! /bin/sh

if [ "$#" -ne 1 ]; then
  echo "Usage: kill-core-process <agency-id>"
  exit 1
fi

AGENCY_ID=$1
echo AGENCY_ID: $AGENCY_ID

PID=`ps -ef | grep java | grep $AGENCY_ID | grep -v ' grep ' | awk '{print $2}'`
echo PID: $PID
kill -6 $PID

