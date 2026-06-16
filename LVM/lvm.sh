#!/bin/bash

DISCO_5G=$(sudo fdisk -l | grep "5 GiB" | awk '{print $2}' | awk -F':' '{print $1}')
DISCO_3G=$(sudo fdisk -l | grep "3 GiB" | awk '{print $2}' | awk -F':' '{print $1}')
DISCO_2G=$(sudo fdisk -l | grep "2 GiB" | awk '{print $2}' | awk -F':' '{print $1}')

sudo wipefs -af $DISCO_5G
sudo wipefs -af $DISCO_3G
sudo wipefs -af $DISCO_2G

sudo fdisk $DISCO_2G << EOF
n
p
1

+1G
t
82
w
EOF

sudo partprobe $DISCO_2G
sudo mkswap ${DISCO_2G}1
sudo swapon ${DISCO_2G}1
echo "${DISCO_2G}1  none  swap  sw  0  0" | sudo tee -a /etc/fstab

sudo pvcreate -f $DISCO_5G
sudo pvcreate -f $DISCO_3G

sudo vgcreate vg_datos $DISCO_5G
sudo vgcreate vg_temp $DISCO_3G

sudo lvcreate --yes -L 10M vg_datos -n lv_docker
sudo lvcreate --yes -L 2.5G vg_datos -n lv_workareas
sudo lvcreate --yes -L 2.5G vg_temp -n lv_swap

sudo mkfs.ext4 -F /dev/mapper/vg_datos-lv_docker
sudo mkfs.ext4 -F /dev/mapper/vg_datos-lv_workareas
sudo mkswap /dev/mapper/vg_temp-lv_swap

sudo mkdir -p /var/lib/docker/
sudo mkdir -p /work/

sudo mount /dev/mapper/vg_datos-lv_docker /var/lib/docker/
sudo mount /dev/mapper/vg_datos-lv_workareas /work/
sudo swapon /dev/mapper/vg_temp-lv_swap

echo "/dev/mapper/vg_datos-lv_docker  /var/lib/docker/  ext4  defaults  0  0" | sudo tee -a /etc/fstab
echo "/dev/mapper/vg_datos-lv_workareas  /work/  ext4  defaults  0  0" | sudo tee -a /etc/fstab
echo "/dev/mapper/vg_temp-lv_swap  none  swap  sw  0  0" | sudo tee -a /etc/fstab

sudo systemctl daemon-reload
sudo mount -a

sudo pvs
sudo vgs
sudo lvs
sudo swapon --show
