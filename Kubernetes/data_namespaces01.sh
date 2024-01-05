#!/bin/bash
#
#KUBECONFIG="/etc/kubernetes/admin.conf"

for namespace in `kubectl get namespace --kubeconfig=/etc/kubernetes/admin.conf|tail -n +2|awk '{print $1}'`;do
    for name in `kubectl get quota --namespace=$namespace --kubeconfig=/etc/kubernetes/admin.conf|tail -n +2|awk '{print $1}'`;do
	kubectl describe quota $name --namespace=$namespace --kubeconfig=/etc/kubernetes/admin.conf
    done
done
