title: js生成html并下载
date: 2019-6-15 11:00:00
tags:
    - js
---


### js生成html并下载

**方案**
- 服务端采用`react`渲染模板，返回`string`
- 前端通过`blob`创建文件，通过`objectUrl`形式触发下载

不多bb，直接上代码

*server端, 采用koa*
```js
import { renderToNodeStream, renderToString } from 'react-dom/server'

async getHtml(ctx) {
  const html = renderToString(React.createElement(...))
  ctx.body = html
}

```

*前端*
```js
fetch({
  ...
}).then((res) => res.blob().then((blob) => {
  const aLink = document.createElement('a')
  const url = window.URL.createObjectURL(blob)
  aLink.href = url
  aLink.download = 'test.html'
  aLink.click()
  window.URL.revokeObjectURL(url)
}))
```