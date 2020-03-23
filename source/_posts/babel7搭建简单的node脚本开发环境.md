
title: babel7搭建简单的node脚本开发工具
date: 2019-7-22 16:00:00
tags:
    - babel
---

## babel7搭建简单的node脚本开发工具

不多bb，上代码

*.babelrc文件*

```js
{
  "presets": [
    [
      "@babel/preset-env",
      {
        "targets": {
          "node": "current"
        }
      }
    ]
  ]
}
```

*package.json*
```js
{
  "name": "test",
  "version": "1.0.0",
  "description": "",
  "main": "index.js",
  "scripts": {
    "dev": "babel-watch -w src src/index.js",
    "build": "rm -rf ./lib && babel ./src/*.js --out-dir lib"
  },
  "author": "huaishuo",
  "license": "ISC",
  "devDependencies": {
    "@babel/cli": "^7.8.4",
    "@babel/core": "^7.8.4",
    "@babel/node": "^7.8.4",
    "@babel/plugin-transform-runtime": "^7.8.3",
    "@babel/preset-env": "^7.8.4",
    "@babel/runtime": "^7.8.4",
    "babel-watch": "^7.0.0"
  }
}

```

然后在*src/index.js*下开发，可以用`es7`特性，打包后的文件在`lib`下
