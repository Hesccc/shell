#!/bin/bash
#
declare -i SUM=0
declare -i I=0
a=$1
b=$2

let sum=$a+$b
echo $sum
let sum=$a-$b
echo $sum
let sum=$a/$b
echo $sum
let sum=$a*$b
while [ $I -le 10 ]; do
	#statements
	let $I+=1
	echo $I
done
echo $sum