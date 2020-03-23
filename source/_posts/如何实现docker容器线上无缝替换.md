title: 如何实现线上docker容器的无缝替换
date: 2019-10-4 15:00:00
tags:
    - docker
    - nginx
---

### 如何实现线上docker容器的无缝替换

在自己博客线上docker容器部署中发现的问题，如果是先停用旧容器，重新构建新镜像新容器，会有一段不可访问的时间。

如何能做到无缝替换呢？下面的demo思路是这样

- 线上容器取名`blog_pro`, 新构建容器取名`blog_pre`，且`端口不指定自动生成`
- 准备一份`nginx proxy模板代码`
- 发布时先构建`blog_pre`，然后`获取blog_pre端口`，根据模板生成`新nginx配置`，`替换nginx配置`文件，`restart`之后，停用删除`blog_pro`, 重命名`blog_pre为blog_pro`

下面是一份简易demo

**nginx模板文件**
```
server {
  listen    80;
  server_name *.huaishuo.top;

  location / {
    proxy_set_header  Host       $host;
    proxy_set_header  X-Real-IP    $remote_addr;
    proxy_set_header  X-Forwarded-For $proxy_add_x_forwarded_for;
    if ($host ~ ^(www)\.huaishuo\.top$){
                  proxy_pass http://127.0.0.1:${blog_port};
    }
    proxy_pass  http://127.0.0.1:3000;
  }
}
```

**node服务代码**
```js
const http = require('http')
const downloadRepo = require('download-git-repo')
const { execSync } = require('child_process')
const fs = require('fs')
const path = require('path')

const resetRepo = () => {
  if (fs.existsSync(path.join(process.cwd(), 'repo'))) {
    execSync('rm -rf repo', { cwd: process.cwd() })
  }

  execSync('mkdir repo', { cwd: process.cwd() })
}

const clearContainer = () => {
  execSync('docker rm -f blog_pre || true', { stdio: 'inherit' })
}

const buildImage = () => {
  execSync('docker build -t="blog" .', { cwd: path.join(process.cwd(), 'repo'), stdio: 'inherit' })
  execSync('docker run --name blog_pre -d -p 3000 blog', { stdio: 'inherit' })
}

const resetNginx = () => {
  const containerPort = execSync('docker port blog_pre').toString('utf8').split(':')[1]
  const conf = fs.readFileSync(`${path.join(process.cwd(), 'model', 'custom.conf')}`, 'utf8')

  fs.writeFileSync('/etc/nginx/conf.d/custom.conf', conf.replace('${blog_port}', containerPort))
  execSync('nginx -s reload', { stdio: 'inherit' })
}

const resetContainer = () => {
  execSync('docker rm -f blog_pro || true', { stdio: 'inherit' })
  execSync('docker rename blog_pre blog_pro', { stdio: 'inherit' })
}

const server = http.createServer((req, res) => {

  if (req.url === '/deploy') {
    try {
      resetRepo()
      // 下载你的项目代码，项目中有DockerFile
      downloadRepo('你的项目git地址', path.join(process.cwd(), 'repo'), (err) => {
        if (err) {
          res.end()
        } else {
          // 清楚可能存在的blog_pre容器
          clearContainer()
          // 构建镜像
          buildImage()
          // 替换nginx文件
          resetNginx();
          // 重置镜像
          resetContainer();
          res.end(JSON.stringify({
            success: true,
            message: '发布成功',
          }))
        }
      })
    } catch (error) {
      res.writeHead(200, {'Content-Type': 'text/plain;charset=utf-8'});
      res.write(error)
      res.end()
    }
  } else {
    res.writeHead(200, {'Content-Type': 'text/plain;charset=utf-8'});
    res.write('测试测试')
    res.end()
  }
})

server.listen(3333)

console.log('server listened at localhost:3333')
```