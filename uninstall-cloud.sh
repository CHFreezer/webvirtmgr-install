#!/bin/sh
echo -e "\033[36m WebVirtCloud, Ubuntu 20.04 LTS 一键卸载脚本 \033[0m"
if [ $USER != "root" ];then
    echo -e "\033[31m 当前用户是${USER}，请用sudo或root用户运行此脚本 \033[0m"
	exit
fi

echo -e "\033[36m 卸载webvirtcloud \033[0m"
rm -rf /srv/webvirtcloud /var/log/supervisor /etc/supervisor/conf.d /var/lib/libvirt /etc/libvirt
apt purge qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virt-manager sasl2-bin python3-guestfs supervisor virtualenv python3-virtualenv python3-dev python3-lxml libvirt-dev zlib1g-dev libxslt1-dev libsasl2-modules -y
apt autoremove --purge -y