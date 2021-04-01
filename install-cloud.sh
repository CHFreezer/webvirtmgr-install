#!/bin/sh
echo -e "\033[36m WebVirtCloud, Ubuntu 20.04 LTS 一键安装脚本 \033[0m"
if [ $USER != "root" ];then
    echo -e "\033[31m 当前用户是${USER}，请用sudo或root用户运行此脚本 \033[0m"
	exit
fi

echo -e "\033[36m 更新apt仓 \033[0m"
apt update
apt install python3

secret_key=$(python3 -c 'import random, string; haystack = string.ascii_letters + string.digits; print("".join([random.SystemRandom().choice(haystack) for _ in range(50)]))')

echo -e "\033[36m 设置用户/组 \033[0m"
read -p "webvirtmgr用户（默认www）：" webvirtmgr_user
webvirtmgr_user=${webvirtmgr_user:-www}
read -p "webvirtmgr组（默认www）：" webvirtmgr_group
webvirtmgr_group=${webvirtmgr_group:-www}

echo -e "\033[36m 安装webvirtcloud \033[0m"
apt install wget git virtualenv python3-virtualenv python3-dev python3-lxml libvirt-dev zlib1g-dev libxslt1-dev supervisor libsasl2-modules gcc pkg-config python3-guestfs -y
sudo git clone https://github.com/retspen/webvirtcloud.git
cd webvirtcloud
cp webvirtcloud/settings.py.template webvirtcloud/settings.py
sed -i "s/SECRET_KEY = \"\"/SECRET_KEY = \"${secret_key}\"/g" webvirtcloud/settings.py
cp conf/supervisor/webvirtcloud.conf /etc/supervisor/conf.d
sed -i "s/user=www-data/user=${webvirtmgr_user}/g" /etc/supervisor/conf.d/webvirtcloud.conf
cd ..
mkdir -p /srv
sudo mv webvirtcloud /srv
chown -R ${webvirtmgr_user}:${webvirtmgr_group} /srv/webvirtcloud
cd /srv/webvirtcloud
virtualenv -p python3 venv
source venv/bin/activate
pip install -r conf/requirements.txt
python3 manage.py migrate
chown -R ${webvirtmgr_user}:${webvirtmgr_group} /srv/webvirtcloud

echo -e "\033[36m 安装KVM \033[0m"
apt install qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virt-manager sasl2-bin python3-guestfs supervisor -y
adduser ${webvirtmgr_user} libvirt
adduser ${webvirtmgr_user} kvm
sed -i 's/libvirtd_opts="-d"/libvirtd_opts="-d -l"/g' /etc/default/libvirtd
sed -i 's/#listen_tls/listen_tls/g' /etc/libvirt/libvirtd.conf
sed -i 's/#listen_tcp/listen_tcp/g' /etc/libvirt/libvirtd.conf
sed -i 's/#auth_tcp/auth_tcp/g' /etc/libvirt/libvirtd.conf
sed -i 's/#[ ]*vnc_listen.*/vnc_listen = "0.0.0.0"/g' /etc/libvirt/qemu.conf
sed -i 's/#[ ]*spice_listen.*/spice_listen = "0.0.0.0"/g' /etc/libvirt/qemu.conf
cp conf/daemon/gstfsd /usr/local/bin/gstfsd
chmod +x /usr/local/bin/gstfsd
cp conf/supervisor/gstfsd.conf /etc/supervisor/conf.d/gstfsd.conf

echo -e "\033[36m 重启服务 \033[0m"
systemctl stop libvirtd
systemctl start libvirtd
systemctl stop supervisor
systemctl start supervisor

echo ""
echo -e "\033[32m 默认用户名：admin，密码：admin \033[0m"
echo -e "\033[32m 最后，请根据https://github.com/CHFreezer/webvirtmgr-install#nginx%E5%BB%BA%E8%AE%AE%E9%85%8D%E7%BD%AE配置nginx, 以完成安装。 \033[0m"
echo -e "\033[32m 如你需要使用本地libvirt-sock，请重启系统，以便使webvirtmgr用户加入libvirt/kvm用户组 \033[0m"