#!/bin/bash

#Start Pyro Name Server
echo "Starting Name Server"
pyro4-ns &

sleep 2
#Start Lcd daemon
echo "Starting LCD Daemon"
./GroveI2cLcd.py -n 0 &

sleep 1
#Start Trackinfo monitor
echo "Start Trackinfo monitor"
./TrackInfo.py -i $HOME/.config/pianobar/song.info -d Grovelcd-0 &

