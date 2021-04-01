#!/bin/sh
echo -e "\033[36m WebVirtMgr, Ubuntu 20.04 LTS 一键卸载脚本 \033[0m"
if [ $USER != "root" ];then
    echo -e "\033[31m 当前用户是${USER}，请用sudo或root用户运行此脚本 \033[0m"
	exit
fi

echo -e "\033[36m 卸载webvirtmgr \033[0m"
rm -rf /var/www/webvirtmgr /var/log/supervisor /etc/supervisor/conf.d /var/lib/libvirt /etc/libvirt
apt purge python python2 python2.7 python-libxml2 novnc supervisor qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils sasl2-bin -y
apt autoremove --purge -y