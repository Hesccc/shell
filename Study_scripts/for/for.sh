#!/bin/bash
#
declare -i SUM=0

for I in {1..100}; do
	#statements
	let SUM+=$I
done
	echo $SUM
