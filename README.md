# webvirtmgr-install
[WebVirtMgr](https://github.com/retspen/webvirtmgr), Ubuntu 20.04 LTS 一键安装脚本

~~刚写完我就后悔了，作者有新仓[WebVirtCloud](https://github.com/retspen/webvirtcloud)，支持Python3~~

现已支持WebVirtCloud一键安装

## 食用方法
```shell
# WebVirtMgr安装
$ wget https://raw.githubusercontent.com/CHFreezer/webvirtmgr-install/main/install.sh -O install.sh
$ chmod +x install.sh && sudo ./install.sh

# WebVirtMgr卸载
$ wget https://raw.githubusercontent.com/CHFreezer/webvirtmgr-install/main/uninstall.sh -O uninstall.sh
$ chmod +x uninstall.sh && sudo ./uninstall.sh

# WebVirtCloud安装
$ wget https://raw.githubusercontent.com/CHFreezer/webvirtmgr-install/main/install-cloud.sh -O install-cloud.sh
$ chmod +x install-cloud.sh && sudo ./install-cloud.sh

# WebVirtCloud卸载
$ wget https://raw.githubusercontent.com/CHFreezer/webvirtmgr-install/main/uninstall-cloud.sh -O uninstall-cloud.sh
$ chmod +x uninstall-cloud.sh && sudo ./uninstall-cloud.sh
```

## 注意事项
1. webvirtmgr安装在/var/www/webvirtmgr，webvirtcloud安装在/srv/webvirtcloud
2. Supervisor服务已配置好在/etc/supervisor/conf.d
3. 需要事先安装好nginx，推荐[宝塔面板](https://www.bt.cn/bbs/thread-19376-1-1.html)，也可以`apt install nginx`
4. 宝塔的nginx用户是www，apt安装的nginx用户是www-data
5. 安装完成后最好重启系统，以便你指定的用户加入libvirt/kvm用户组生效，[官方指南](https://help.ubuntu.com/community/KVM/Installation)指出After this, **you need to relogin**，也就是说指定用户重新登录也可以加入用户组生效，但具体操作方法暂未研究
6. 重启完成后，可访问nginx配置好的网页，登录你安装时设置好的账号密码，点击Add Connection -> Local Socket -> Label随便填，即可管理你的KVM

## Nginx建议配置
```nginx
# WebVirtMgr
server {
    listen 80;

    server_name $hostname;
    #access_log /var/log/nginx/webvirtmgr_access_log; 

    location /static/ {
        root /var/www/webvirtmgr/webvirtmgr; # or /srv instead of /var
        expires max;
    }

    location ~ .*\.(js|css)$ {
           proxy_pass http://127.0.0.1:8000;
    }

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-for $proxy_add_x_forwarded_for;
        proxy_set_header Host $host:$server_port;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_connect_timeout 600;
        proxy_read_timeout 600;
        proxy_send_timeout 600;
        client_max_body_size 1024M; # Set higher depending on your needs 
    }
}
```
```nginx
# WebVirtCloud
server {
    listen 80;

    #server_name webvirtcloud.example.com;
    #access_log /var/log/nginx/webvirtcloud-access_log; 

    location /static/ {
        root /srv/webvirtcloud;
        expires max;
    }

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-for $proxy_add_x_forwarded_for;
        proxy_set_header Host $host:$server_port;
        proxy_set_header X-Forwarded-Proto $remote_addr;
        proxy_set_header X-Forwarded-Ssl off;
        proxy_connect_timeout 1800;
        proxy_read_timeout 1800;
        proxy_send_timeout 1800;
        client_max_body_size 1024M;
    }

    location /novncd/ {
        proxy_pass http://wsnovncd;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}

upstream wsnovncd {
      server 127.0.0.1:6080;
}
```
