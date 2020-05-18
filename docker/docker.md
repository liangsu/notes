# docker

## 1.安装
参考：https://www.runoob.com/docker/centos-docker-install.html

### 1.1 安装命令
```
// 安装一些必要的系统工具：
sudo yum install -y yum-utils device-mapper-persistent-data lvm2

// 添加软件源信息：设置yum源
sudo yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

// 更新 yum 缓存：
sudo yum makecache fast

// 安装 Docker-ce：
sudo yum -y install docker-ce
```

### 1.2 docker启动和停止

* 启动docker： systemctl start docker
* 停止docker： systemctl stop docker
* 重启docker： systemctl restart docker
* 查看docker状态：systemctl status docker
* 开机启动：systemctl enable docker
* 查看docker概要信息：	docker info
* 查看docker帮助文档：	docker --help


### 1.3 设置镜像

在目录/etc/docker/daemon.json下设置，没有文件则增加：
```json
{
	"registry-mirrors": ["https://docker.mirrors.ustc.edu.cn"]
}
```

## 2.常用命令

### 2.1 镜像相关命令

查看镜像： docker images
搜索镜像： docker search 镜像名称
拉取镜像： docker pull 镜像名称			docker pull centos:7
删除镜像： docker rmi 镜像ID
删除所有镜像： docker rmi `docker images -q`

### 2.2 容器相关命令

查看正在运行的容器： docker ps
查看所有容器： docker ps –a
查看最后一次运行的容器： docker ps -l
查看停止的容器： docker ps -f status=exited

进入容器： docker exec -it 容器名称/id

查看容器详细信息： docker inspect 容器名称/id  /bin/bash

启动容器： docker start 容器名称/id
停止容器： docker stop  容器名称/id




docker inspect --format='{{.NetworkSettings.IPAddress}}' hm-zookeeper




### 常见问题：
1. 安装mysql时区不正确：  https://www.cnblogs.com/luodengxiong/p/11374495.html

my.cnf文件：
```
default-time-zone = '+8:00'
```

Dockerfile:
```
FROM mysql:5.7.22

ADD *.sql /home/
ADD *.sh /home/
ADD mysql.cnf /etc/mysql/conf.d/
RUN chmod +x /home/init.sh
```

























