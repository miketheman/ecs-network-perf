#!/usr/bin/execlineb -S0
# Any service with this script named <svcdir>/finish will exit if the process fails
s6-svscanctl -t /var/run/s6/services
