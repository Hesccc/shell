#!/bin/bash
#
#kubectl describe pv --kubeconfig=/etc/kubernetes/admin.conf
#export KUBECONFIG=/etc/kubernetes/admin.conf

kubectl describe pvc --kubeconfig=/etc/kubernetes/admin.conf > kubectl_pvc
kubectl describe pv  --kubeconfig=/etc/kubernetes/admin.conf > kubectl_pv

for volume_ in `cat kubectl_pvc | grep 'Volume:' | awk -F: '{gsub(/ /,"",$2);print $2}'`;do
for path_ in `cat kubectl_pv | grep -A 20 $volume_ | grep Path: | awk -F: '{gsub(/ /,"",$2);print $2}'`;do
used_=`sudo du -sk $path_ | awk '{val=gsub("$path","",$1)};{print $1}'`
for total_ in `cat kubectl_pv | grep -A 20 $volume_ | grep Capacity: | awk -F: '{gsub(/ /,"",$2);print $2}'`;do
for type_ in `cat kubectl_pv | grep -A 20 $volume_ | grep Type: | awk -F: '{sub(/^[ \t]+/,"",$2);print $2}' | cut -c 1-3`;do
for status_ in `cat kubectl_pv | grep -A 20 $volume_ | grep Status: | awk -F: '{gsub(/ /,"",$2);print $2}'`;do
echo volume=\"$volume_\",path=\"$path_\",used=\"$used_\",total=\"$total_\",type=\"$type_\",status=\"$status_\"
done
done
done
done
done

