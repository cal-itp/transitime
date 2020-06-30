#!/usr/bin/env bash

echo -n'starting RMI registry...'

rmiregistry &

echo 'done'

tail -f /dev/null
