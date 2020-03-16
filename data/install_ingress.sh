#!/bin/bash

check=""
case $check in
    "${NAMESPACE}")
      print "namespace is required"
      exit 1
      ;;
    "${PROXY_HTTP_PORT}")
      print "PROXY_HTTP_PORT is required"
      exit 1
      ;;
    "${PROXY_HTTPS_PORT}")
      print "PROXY_HTTPS_PORT is required"
      exit 1
      ;;
esac

kubectl taint nodes --all node-role.kubernetes.io/master- # comment this command if you don't want the scheduler will be able to schedule Pods on master node
helm repo add nginx https://helm.nginx.com/stable
helm repo update
kubectl create namespace ${NAMESPACE}
helm install ${NAMESPACE} nginx/nginx-ingress \
    --set controller.service.type=NodePort,controller.service.httpPort.nodePort=${PROXY_HTTP_PORT},controller.service.httpsPort.nodePort=${PROXY_HTTPS_PORT},controller.service.externalTrafficPolicy=Cluster \
    --namespace=${NAMESPACE}