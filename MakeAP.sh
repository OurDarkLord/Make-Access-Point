#!/bin/bash

#global variabels 
gateway=""
gatewayIp=""
oldmetric=""
WlanInterface=""
#functions

gateway=$(route -n |grep "eth0"| grep "UG")


if [ -n "$gateway" ] ;then
	echo "Ethernet Connection detected"

	gatewayIp=$(awk -F " " '{print $2}' <<< "$gateway")
	oldmetric=$(awk -F " " '{print $5}' <<< "$gateway")

	echo "gateway ip is = $gatewayIp"
	echo "old metric = $oldmetric"
	if [ $oldmetric != 1 ] ;then
		
		echo "inserting new metric"
		route add -net default gw $gatewayIp netmask 0.0.0.0 dev eth0 metric 1
		echo "removing old metric"
		route del -net default gw $gatewayIp netmask 0.0.0.0 dev eth0 metric $oldmetric
	else
		echo "metric already 1"
	fi	
	echo "Using Ethernet for internet"

	WlanInterface=$(iw dev | awk -F " " 'NR==2 {print $2}' | grep "wlan")
	echo "Interface that will be used for the AP = $WlanInterface"
else
	echo "No ethernet connection, checking for wlan0"
	gateway=$(route -n |grep "wlan0"| grep "UG")
	if [ -n "$gateway" ] ;then
		echo "Wlan internet connection found"
	
		gatewayIp=$(awk -F " " '{print $2}'<<< "$gateway")
		echo "gateway ip is = $gatewayIp"
		oldmetric=$(awk -F " " '{print $5}' <<< "$gateway")
		echo "old metric = $oldmetric"

		if [ $oldmetric != 1 ] ;then
			echo "inserting new metric"
			route add -net default gw $gatewayIp netmask 0.0.0.0 dev wlan0 metric 1
			echo "removing old metric"
			route del -net default gw $gatewayIp netmask 0.0.0.0 dev wlan0 metric $oldmetric 
		else
			echo "metric already 1"
		fi
		echo "Using Wlan0 for internet"

		WlanInterface=$(iw dev | awk -F " " 'NR==2 {print $2}' | grep "wlan")
		echo "Interface that will be used for the AP = $WlanInterface"
		if [ $WlanInterface != "wlan0" ] ;then
			echo "making AP"
		else
			echo "Wlan already in use, insert wifi usb or ethernet"
			echo "quitting!!!"
		fi
		
	else
		echo "No internet connection found"
	fi
fi
