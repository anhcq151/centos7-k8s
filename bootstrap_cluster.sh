#!/bin/bash

echo "---RUNNING BOOTSTRAP CLUSTER---"

# Add sysctl settings
echo "[TASK 1] Add sysctl settings"
cat >>/etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system >/dev/null 2>&1

# Disable swap
echo "[TASK 2] Disable and turn off SWAP"
sed -i '/swap/d' /etc/fstab
swapoff -a

# Add yum repo file for Kubernetes
echo "[TASK 3] Add yum repo file for kubernetes"
cat >>/etc/yum.repos.d/kubernetes.repo<<EOF
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
        https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

# Install Kubernetes
echo "[TASK 4] Install Kubernetes (kubeadm, kubelet and kubectl)"
yum install -y -q kubeadm kubelet kubectl >/dev/null 2>&1

# Start and Enable kubelet service
echo "[TASK 5] Enable and start kubelet service"
systemctl enable kubelet >/dev/null 2>&1
systemctl start kubelet >/dev/null 2>&1

# Enable ssh password authentication
echo "[TASK 6] Enable ssh password authentication"
sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
systemctl reload sshd

# Set Root password
echo "[TASK 7] Set root password"
echo "kubeadmin" | passwd --stdin root >/dev/null 2>&1

# Update vagrant user's bashrc file
# echo "export TERM=xterm" >> /etc/bashrc
