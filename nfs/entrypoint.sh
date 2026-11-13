#!/bin/sh
# NFSv4-only, read-only export of /export to $PERMITTED
set -e
mkdir -p /var/lib/nfs/rpc_pipefs /var/lib/nfs/v4recovery /proc/fs/nfsd
mountpoint -q /var/lib/nfs/rpc_pipefs || mount -t rpc_pipefs rpc_pipefs /var/lib/nfs/rpc_pipefs
mountpoint -q /proc/fs/nfsd || mount -t nfsd nfsd /proc/fs/nfsd
echo "/export ${PERMITTED:-192.168.100.0/24}(ro,fsid=0,sync,no_subtree_check,all_squash,anonuid=1000,anongid=1000)" > /etc/exports
exportfs -rv
rpc.nfsd -N 3 -V 4 8
exec rpc.mountd -F -N 3 -V 4
