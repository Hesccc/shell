#!/bin/sh
#

STRING='heshuncheng'

if [ -z $STRING ]; then 
    echo "STRING is empty" 
fi

if [ -n $STRING ]; then 
    echo "STRING is not empty" 
fi 