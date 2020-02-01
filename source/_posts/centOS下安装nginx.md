---
layout: 阿里云服务器ecs
title: centOS7安装nginx
date: 2016-08-03 21:16:24
tags:
    - centOS
    - nginx
---

**1.连接自己的服务器**

```
ssh root@113.25.35.52
```
替换成你自己的ip

**2.使用yum安装Nginx**

```
yum install nginx
```

**3.启动Nginx**

刚安装的Nginx不会自行启动。运行Nginx以及设置开机自启:
```
systemctl start nginx.service
```
```
systemctl enable nginx.service
```
如果一切进展顺利的话，现在你可以通过你的域名或IP来访问你的Web页面来预览一下Nginx的默认页面

**4.Nginx配置信息**
```
网站文件存放默认目录

/usr/share/nginx/html
网站默认站点配置

/etc/nginx/conf.d/default.conf
自定义Nginx站点配置文件存放目录,自己在这里也可以定义别的名字的.conf，这个的作用以后再说。

/etc/nginx/conf.d/
Nginx全局配置

/etc/nginx/nginx.conf
在这里你可以改变设置用户运行Nginx守护程序进程一样,和工作进程的数量得到了Nginx正在运行,等等。
```

**5.Nginx基本语法**
```
nginx -t   						#测试配置文件是否有语法错误
nginx -s reopen					#重启Nginx
nginx -s reload					 #重新加载Nginx配置文件，然后以优雅的方式重启Nginx
nginx -s stop  					#强制停止Nginx服务
nginx -s quit  						#优雅地停止Nginx服务（即处理完所有请求后再停止服务）
nginx -c [配置文件路径]       #为 Nginx 指定配置文件
```