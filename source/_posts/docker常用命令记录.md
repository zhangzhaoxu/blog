title: docker常用命令记录
date: 2019-5-12 11:00:00
tags:
    - docker
---

## docker常用命令记录

- 已存在镜像的情况下，启动一个容器，指定映射端口，指定挂载目录
```js
docker run --name `containerName` -d -p 8888:3000 -v `原始绝对路径`:`容器绝对路径` `imageName`
```

- 已存在镜像情况下，启动一个容器，将容器的某个端口映射到主机的任意端口
- 查看这个容器的映射端口
```js
docker run --name `containerName` -d -p 3000 `imageName`
docker port `containerId`
```

- 与容器的运行环境交互
```js
docker exec -it `containerId` sh
```

- 从一个`Dockerfile`构建镜像
```js
docker build -t="test" `Dockerfile路径`
```

