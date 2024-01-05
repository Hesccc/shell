#!/bin/bash
#

declare -i V_NUM=0
declare -i SHOWUSER=0

for i in `seq 1 $#`; do
	if [ $# -gt 0 ]; then
	 case $1 in
	 	-h|--help)
	 	echo "Usage: `basename $0` -c|--count -v|--verbose -h|--help"
		exit 0;;
		-v|--verbose)
		let V_NUM=1
		shift ;;
		-c|--count)
		let SHOWUSER=1
		shift ;;
		*)
		echo "Usage: `basename $0` -c|--count -v|--verbose -h|--help"
		exit 2;;
	 esac
	fi
done

if [ $SHOWUSER -eq 1 ]; then
	#statements
	echo "当前登录用户为：`who |wc -l`"
	if [ $V_NUM -eq 1 ]; then
		#statements
		who
	fi
fi
