#! /bin/sh

if [ "$#" -ne 1 ]; then
  echo "Usage: kill-instance.sh <instance>" >&2
  exit 1
fi
