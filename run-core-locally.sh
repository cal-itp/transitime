#! /bin/sh

# to remove code logs:
# find logs/halifax -name "*.log" -exec rm {} \; -print

if [ "$#" -ne 1 ]; then
  echo "Usage: setup-agency <agency-id>" >&2
  exit 0
fi

AGENCY_ID=$1
PROP_FILE=${AGENCY_ID}.properties

echo AGENCY_ID=$AGENCY_ID
echo PROP_FILE=$PROP_FILE
echo


java \
  -Dtransitclock.configFiles=$PROP_FILE \
  -Dtransitclock.logging.dir=logs \
  -Dtransitclock.rmi.rmiHost=127.0.0.1 \
  -jar transitclock/target/Core.jar


