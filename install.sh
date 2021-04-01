#!/bin/sh
echo -e "\033[36m WebVirtMgr, Ubuntu 20.04 LTS 一键安装脚本 \033[0m"
if [ $USER != "root" ];then
    echo -e "\033[31m 当前用户是${USER}，请用sudo或root用户运行此脚本 \033[0m"
	exit
fi

echo -e "\033[36m 更新apt仓 \033[0m"
add-apt-repository universe
apt update

echo "\033[36m 设置用户/组 \033[0m"
read -p "webvirtmgr用户（默认www）：" webvirtmgr_user
webvirtmgr_user=${webvirtmgr_user:-www}
read -p "webvirtmgr组（默认www）：" webvirtmgr_group
webvirtmgr_group=${webvirtmgr_group:-www}

echo "\033[36m 安装KVM \033[0m"
apt install qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils -y
adduser ${webvirtmgr_user} libvirt
adduser ${webvirtmgr_user} kvm

echo "\033[36m 安装依赖 \033[0m"
apt install wget git python python-libxml2 novnc supervisor -y
wget http://archive.ubuntu.com/ubuntu/pool/main/libv/libvirt-python/python-libvirt_4.0.0-1_amd64.deb -O python-libvirt_4.0.0-1_amd64.deb
dpkg -i python-libvirt_4.0.0-1_amd64.deb
rm -f python-libvirt_4.0.0-1_amd64.deb

echo "\033[36m 安装pip \033[0m"
wget https://bootstrap.pypa.io/pip/2.7/get-pip.py -O get-pip.py
python get-pip.py
rm -f get-pip.py

echo "\033[36m 安装webvirtmgr \033[0m"
git clone git://github.com/retspen/webvirtmgr.git
cd webvirtmgr
pip install -r requirements.txt
pip install websockify
./manage.py syncdb
./manage.py collectstatic
cd ..

echo "\033[36m 设置webvirtmgr \033[0m"
sudo mv webvirtmgr /var/www/
chown -R ${webvirtmgr_user}:${webvirtmgr_group} /var/www/webvirtmgr

cat > webvirtmgr.conf <<EOF
[program:webvirtmgr]
command=/usr/bin/python /var/www/webvirtmgr/manage.py run_gunicorn -c /var/www/webvirtmgr/conf/gunicorn.conf.py
directory=/var/www/webvirtmgr
autostart=true
autorestart=true
stdout_logfile=/var/log/supervisor/webvirtmgr.log
redirect_stderr=true
user=${webvirtmgr_user}

[program:webvirtmgr-console]
command=/usr/bin/python /var/www/webvirtmgr/console/webvirtmgr-console
directory=/var/www/webvirtmgr
autostart=true
autorestart=true
stdout_logfile=/var/log/supervisor/webvirtmgr-console.log
redirect_stderr=true
user=${webvirtmgr_user}
EOF
mv webvirtmgr.conf /etc/supervisor/conf.d/
systemctl stop supervisor
systemctl start supervisor
systemctl enable supervisor

echo ""
echo "\033[32m 最后，请在nginx中手动添加proxy_pass http://127.0.0.1:8000; 以完成安装。 \033[0m"
echo "\033[32m 如你需要使用本地libvirt-sock，请重启系统，以便使webvirtmgr用户加入libvirt/kvm用户组 \033[0m"
