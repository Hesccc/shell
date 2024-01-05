#!/bin/bash
#
case $1 in
	'start')
	echo 'start server ...'	;;
	'stop')
	echo 'stop server ...' ;;
	'restart')
	echo 'restart server ...' ;;
	'starrtus')
	echo 'starrtus server ...' ;;
	*)
	echo 'start|stop|restart|startus ...'
esac
