#!/bin/bash

if [ $# -ne 1 ]; then
	echo "Please input the root dir!"
	echo "Usage: ./$0 new_root_dir"
	exit
fi

# new root dir
NEW_ROOT=$1

# mount file system
mount -v --bind /dev ${NEW_ROOT}/dev
mount -vt devpts devpts ${NEW_ROOT}/dev/pts
mount -vt proc proc ${NEW_ROOT}/proc
mount -vt sysfs sysfs ${NEW_ROOT}/sys

if [ -h ${NEW_ROOT}/dev/shm ]; then
  link=$(readlink ${NEW_ROOT}/dev/shm)
  mkdir -p ${NEW_ROOT}/$link
  mount -vt tmpfs shm ${NEW_ROOT}/$link
  unset link
else
  mount -vt tmpfs shm ${NEW_ROOT}/dev/shm
fi

# chroot
chroot "${NEW_ROOT}" /bin/env -i  \
    HOME=/root                  \
    SHELL=/bin/bash             \
    TERM="$TERM"                \
    PS1='\u:\w\$ '              \
    PATH=/bin:/usr/bin:/sbin:/usr/sbin \
    /bin/bash --login +h

# umount
umount -v ${NEW_ROOT}/dev/shm
umount -v ${NEW_ROOT}/sys
umount -v ${NEW_ROOT}/proc
umount -v ${NEW_ROOT}/dev/pts
umount -v ${NEW_ROOT}/dev
