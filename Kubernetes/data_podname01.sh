#!/bin/bash
#
kubectl get pod --all-namespaces -o wide --kubeconfig=/etc/kubernetes/admin.conf | awk '{if(NR>1)print}'


