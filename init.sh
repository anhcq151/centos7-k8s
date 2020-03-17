#!/bin/bash

echo "---RUNNING BOOTSTRAP---"

# Update hosts file
echo "[TASK 1] Update /etc/hosts file"
cat >>/etc/hosts<<EOF
172.16.15.13 k8s-head
172.16.15.14 k8s-node-1
172.16.15.15 k8s-node-2
172.16.15.16 k8s-nfs
172.16.15.17 k8s-lb
EOF

# Disable SELinux
echo "[TASK 2] Disable SELinux"
setenforce 0
sed -i --follow-symlinks 's/^SELINUX=enforcing/SELINUX=disabled/' /etc/sysconfig/selinux

# Stop and disable firewalld
echo "[TASK 3] Stop and Disable firewalld"
systemctl disable firewalld >/dev/null 2>&1
systemctl stop firewalld

yum update -y