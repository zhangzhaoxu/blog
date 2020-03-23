title: babel7搭建简单的node脚本开发工具
date: 2017-11-7 16:00:00
tags:
    - 日常
---

## JS调用复制碰到的坑

*先上正确代码*
```js
  const input = document.createElement('input')
  document.body.appendChild(input)
  input.setAttribute('value', codes[selectedCode])
  input.select()
  
  if (document.execCommand('copy')) {
    document.execCommand('copy')
  }

  document.body.removeChild(input)
```

*遇到的第一个问题*

input标签如果设置style的width和height为0会失效，所以请设置opacity=0。

*第二个问题*

input标签必须塞一次删一次，如果一直用一个input标签，通过`setAttribute('value', 'xxx')`的方式的话，只有第一次会生效，也不明白为什么。
