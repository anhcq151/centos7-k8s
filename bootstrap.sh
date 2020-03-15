#!/bin/bash

# Update hosts file
echo "[TASK 1] Update /etc/hosts file"
cat >>/etc/hosts<<EOF
172.16.15.13 k8s-head
172.16.15.14 k8s-node-1
172.16.15.15 k8s-node-2
172.16.15.16 k8s-nfs
#172.16.15.17 k8s-lb
EOF

# Install docker from Docker-ce repository
# echo "[TASK 2] Install docker container engine"
# yum install -y yum-utils device-mapper-persistent-data lvm2
# yum-config-manager --add-repo \
#   https://download.docker.com/linux/centos/docker-ce.repo

# yum update -y && yum install -y \
#   containerd.io-1.2.10 \
#   docker-ce-19.03.4 \
#   docker-ce-cli-19.03.4

# ## Create /etc/docker directory.
# mkdir /etc/docker

# # Setup daemon.
# cat > /etc/docker/daemon.json <<EOF
# {
#   "exec-opts": ["native.cgroupdriver=systemd"],
#   "log-driver": "json-file",
#   "log-opts": {
#     "max-size": "100m"
#   },
#   "storage-driver": "overlay2",
#   "storage-opts": [
#     "overlay2.override_kernel_check=true"
#   ]
# }
# EOF

# mkdir -p /etc/systemd/system/docker.service.d

# systemctl daemon-reload
# systemctl restart docker
# # Enable docker service
# echo "[TASK 3] Enable and start docker service"
# systemctl enable docker >/dev/null 2>&1
# systemctl start docker

# Disable SELinux
echo "[TASK 4] Disable SELinux"
setenforce 0
sed -i --follow-symlinks 's/^SELINUX=enforcing/SELINUX=disabled/' /etc/sysconfig/selinux

# Stop and disable firewalld
echo "[TASK 5] Stop and Disable firewalld"
systemctl disable firewalld >/dev/null 2>&1
systemctl stop firewalld

# Add sysctl settings
echo "[TASK 6] Add sysctl settings"
cat >>/etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system >/dev/null 2>&1

# Disable swap
echo "[TASK 7] Disable and turn off SWAP"
sed -i '/swap/d' /etc/fstab
swapoff -a

# Add yum repo file for Kubernetes
echo "[TASK 8] Add yum repo file for kubernetes"
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
echo "[TASK 9] Install Kubernetes (kubeadm, kubelet and kubectl)"
yum install -y -q kubeadm kubelet kubectl >/dev/null 2>&1

# Start and Enable kubelet service
echo "[TASK 10] Enable and start kubelet service"
systemctl enable kubelet >/dev/null 2>&1
systemctl start kubelet >/dev/null 2>&1

# Enable ssh password authentication
echo "[TASK 11] Enable ssh password authentication"
sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
systemctl reload sshd

# Set Root password
echo "[TASK 12] Set root password"
echo "kubeadmin" | passwd --stdin root >/dev/null 2>&1

# Update vagrant user's bashrc file
echo "export TERM=xterm" >> /etc/bashrc
