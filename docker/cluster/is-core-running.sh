#! /bin/sh

ps -ef | grep java.*$1 | grep -v ' grep '