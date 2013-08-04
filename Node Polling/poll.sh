#!/bin/bash
#############################################
# Script is part of the TrackNode project.
# Licensing and other information is available at http://sourceforge.net/projects/tracknode
# Developer offers NO WARRANTY for this product
# Software is in experimental development stage - use at your own risk
#############################################


# INFINITE LOOP bash script to poll DHT11 sensor on pin 4 of the raspberry pi and output for pollTempHum.pl.  Will occasionally fail.
# Requires bash, grep, cut commands, as well as Adafruit_DHT, which is licensed independently of this project
# Meant to run as a startup service, within rc.local


while : 
do
	TEMPOUT=$(sudo /home/pi/gpio/Adafruit-Raspberry-Pi-Python-Code/Adafruit_DHT_Driver/Adafruit_DHT 11 4 | grep Temp | cut -f 3,7 -d ' ')
	if [ -z "$TEMPOUT" ]; then
		continue
	else
		echo $TEMPOUT > /home/pi/scripts/temp.log
	fi
	sleep 2
done

