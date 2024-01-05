#!/bin/bash
#
kubectl describe service --all-namespaces --kubeconfig=/etc/kubernetes/admin.conf > .content

for name_  in `cat .content | grep Name:|awk -F " " '{print $2}'`;do
for namespace_ in `cat .content | grep -A 2 $name_ | grep Namespace: | awk -F" " '{print $2}'`;do
for selector_ in  `cat .content | grep -A 14  $name_ | grep Selector: | awk -F" " '{print $2}'`;do
for ip_ in `cat .content | grep -A 14 $name_ |grep -A 3  $selector_ | grep IP: | awk -F" " '{print $2}'`;do
for port_ in `cat .content | grep -A 14 $name_ | grep -A 1 $ip_ | grep "Port:" | awk -F" " '{print $3}'`;do
for endpoints_ in `cat .content | grep -A 14 $name_ | grep -A 3 $ip_ | grep "Endpoints:" | awk -F" " '{print $2}'`;do
echo "name:"$name_ "|namespace:"$namespace_ "|selector:"$selector_ "|ip:"$ip_ "|port:"$port_"|Endpoints:"$endpoints_
done
done
done
done
done
done
