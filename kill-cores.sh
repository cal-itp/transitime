#! /bin/sh

for i in `ps -ef | grep java | grep Dtransitclock.configFiles | awk '{print $2}'`
do
  kill -11 $i
done
