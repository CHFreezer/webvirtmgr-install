# webvirtmgr-install
WebVirtMgr, Ubuntu 20.04 LTS 一键安装脚本

## 食用方法
```shell
$ wget https://raw.githubusercontent.com/CHFreezer/webvirtmgr-install/main/install.sh -O install.sh
$ chmod +x install.sh && sudo ./install.sh
```

## 注意事项
1. webvirtmgr安装在/var/www/webvirtmgr
2. Supervisor服务已配置好在`/etc/supervisor/conf.d/webvirtmgr.conf`
3. `$ ./manage.py runserver 0:8000`可以启动debug模式，需要先停止Supervisor服务`systemctl stop supervisor`，之后可浏览器访问http://x.x.x.x:8000 (x.x.x.x - 你服务器IP)
4. novnc服务是`./console/webvirtmgr-console`
5. 需要事先安装好nginx，推荐[宝塔面板](https://www.bt.cn/bbs/thread-19376-1-1.html)，也可以`apt install nginx`
6. 宝塔的nginx用户是www，apt安装的nginx用户是www-data
7. 安装完成后最好重启系统，以便你指定的用户加入libvirt/kvm用户组生效，[官方指南](https://help.ubuntu.com/community/KVM/Installation)指出After this, **you need to relogin**，也就是说指定用户重新登录也可以加入用户组生效，但具体操作方法暂未研究
8. 重启完成后，可访问nginx配置好的网页，登录你安装时设置好的账号密码，点击Add Connection -> Local Socket -> Label随便填，即可管理你的KVM

## Nginx建议配置
```nginx
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