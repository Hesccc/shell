#!/bin/bash
#
declare -i I=1
declare -i SUM=0

while [ $I -le 100 ]; do
	let SUM+=$I
	let I++
	echo "SUM:"$SUM
	echo "I:"$I
done