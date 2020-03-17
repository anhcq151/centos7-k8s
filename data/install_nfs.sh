#!/bin/bash

if [ "${NAMESPACE}" == "" ]
then
    echo "NAMESPACE is required"
    exit 1
fi

helm repo add stable https://kubernetes-charts.storage.googleapis.com
helm repo update
kubectl create namespace ${NAMESPACE}
helm install ${NAMESPACE} \
    --set nfs.server=k8s-nfs \
    --set nfs.path=/var/nfsshare \
    --set storageClass.reclaimPolicy=Retain \
    --namespace ${NAMESPACE} \
    stable/nfs-client-provisioner