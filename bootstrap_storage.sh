#!/bin/bash

echo "---RUNNING BOOTSTRAP STORAGE---"
mkdir /var/nfsshare
chmod -R 755 /var/nfsshare
chown nfsnobody:nfsnobody /var/nfsshare
systemctl enable rpcbind
systemctl enable nfs-server
systemctl enable nfs-lock
systemctl enable nfs-idmap
systemctl start rpcbind
systemctl start nfs-server
systemctl start nfs-lock
systemctl start nfs-idmap
echo "/var/nfsshare    172.16.15.0/24(rw,sync,no_root_squash,no_all_squash,no_subtree_check)" >> /etc/exports
systemctl restart nfs-server