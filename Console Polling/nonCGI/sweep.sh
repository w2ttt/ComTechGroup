#!/bin/sh

cat /dev/null > sweepresults.txt
for i in `seq 1 254`;do 
ping -c1 172.27.0.$i|grep time | cut -f4 -d' '|cut -f1 -d':'>>sweepresults.txt&
sleep 0.2
done
