#!/bin/bash

# set network
modprobe tun
tunctl
ip link set tap0 up
ifconfig tap0 192.168.0.11/24
echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -F
iptables -t nat -A POSTROUTING -j MASQUERADE

# start qemu
qemu-kvm -m 512 -drive file=debian.img,cache=writeback -localtime -boot c -cdrom /dev/sr0 -smp 2 -net nic,model=rtl8139 -net tap,ifname=tap,script=no,downscript=no

# rdesktop
rdesktop -u Ray -r clipboard:PRIMARYCLIPBOARD -r disk:remote=/home/Ray -a 24 -x l -g 90% 192.168.0.5:3389

# mount disk
losetup debian.img /dev/loop0
kpartx -a /dev/loop0
mount /dev/mapper/loop0p1 /mnt

# convert image
qemu-img convert -f qcow2 file.qcow2 -O raw file.raw
