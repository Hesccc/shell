#!/bin/bash
timestamp=`date +%s`
for idev in `cat /proc/net/dev | awk '{i++; if(i>2){print $1}}' | sed 's/^[\t]*//g' | sed 's/[:]*$//g'|grep -vw lo`;do
    ifconfig|grep -A 7 $idev|sed -n '/RX packets/,/TX errors/'p > /tmp/.${idev}_info
    RXpackets=`cat /tmp/.${idev}_info|head -1|awk '{print $3}'`
    RXbytes=`cat /tmp/.${idev}_info|head -1|awk '{print $5}'`
    RXerrors=`cat /tmp/.${idev}_info|sed -n 2p|awk '{print $3}'`
    TXpackets=`cat /tmp/.${idev}_info|sed -n 3p|tail -1|awk '{print $3}'`
    TXbytes=`cat /tmp/.${idev}_info|sed -n 3p|awk '{print $5}'`
    TXerrors=`cat /tmp/.${idev}_info|tail -1|tail -1|awk '{print $3}'`
    echo $timestamp $idev RXpackets=$RXpackets RXbytes=$RXbytes RXerrors=$RXerrors TXpackets=$TXpackets TXbytes=$TXbytes TXerrors=$TXerrors
done
