---
title: H5唤醒app方式汇总
date: 2019-04-3 15:00:00
tags:
    - javascript
    - H5与app交互
---


### H5唤醒App方式汇总

最近在做扫码之后的h5页面唤醒App的功能，做下记录

**1.唤醒方式列表**
- URL Schemes
- chrome intent
- ios UniversalLink / android appLink

**2.常见唤醒媒介**
- iframe
- a标签
- window.location
- URL Scheme

**3.组成**
```
[scheme:][//authority][path][?query] 比如：tuyasmart://home?test=1
```

**4.是什么**

*URL Schemes*可以理解为一种特殊的URL用来定位一个应用以及应用内的某个功能，类比网页链接便很容易理解
*Schemes* 表示的是URL中的一个位置 - 最初始的位置，既`://`之前的字符，比如`https://www.apple.com`的*Schemes*就是`https`
通过*URL Schemes*, 我们就可以像定位一个网页一样，定位一个应用甚至应用内的某个具体的功能。而定位是哪个应用的，就是*Schemes*部分。比如短信应用的Schemes就是： sms
我们完全可以按照理解一个网页的URL来理解一个应用的URL
|| 网页（苹果）| 应用（微信）| 
| 网站首页/打开应用 | https://www.apple.com | weixin:// |
| 子页面/具体功能  | .../mac (Mac应用页) | weixin://dl/moments（朋友圈） |
注意点 - 应用是否支持*URL Schemes*要看App开发者有没有写那部分的代码了 - *URL Schemes* 不唯一

**5.使用**
使用方式十分简单，就像我们打开一个链接一样，常见的有
- location.href
- iframe
- a标签

**6.使用中常见问题及解决方案**

- 可能会被app禁掉，比如微信，qq等
- ios9+ 禁止掉了iframe方式。
- ios及部分安卓浏览器会提示用户是否打开App，并且ios在未安装对应App的时候，会提示“打不开网页，因为该网址无效”
h5无法感知是否唤醒成功
- 大部分浏览器需要用户手动触发链接，js自动触发无效

针对被app禁止掉的情况，通常会判断是否微信等app环境，然后提示用户浏览器内打开 针对*ios9+ iframe* 被禁掉的情况，判断下ios版本 针对h5无法感知是否唤醒成功的解决办法是，`一段时间之后自动跳转下载页，或者是依赖setTimeout在浏览器进入后台后进程切换导致的时间延迟判断`。

**7.Intent**

安卓的原生谷歌浏览器从*chrome25*版本之后就不能通过*URL Schemes*唤醒安卓应用。要使用谷歌官方提供的*intent:*预发， 如果唤醒失败，则会跳转到谷歌的应用市场。语法与*URL Schemes*及其相似，相当于谷歌定制版的URL Schemes，也没用过，就不多说。


**8.IOS Universal Link**
简介 *Universal Link*是在iOS9引入的新功能，通过传统的HTTP链接就可以唤醒app，如果用户没有安装APP，则会跳转到该链接对应的页面，而且在唤醒app的时候没有弹框提示哦。可以说是解决了URL Schemes的大部分问题。

*原理及流程*
- App开发人员去配置中心配置Associated Domain配置一个支持https的域名，比如app-support.test.com
- 然后 app-support.test.com/apple-app-site-association或者app-support.test.com/apple-app-site-association/.well-known/apple-app-site-association要返回app的teamId,bundleId,paths信息

```js
router.get('/apple-app-site-association, (req, res) => {
  const data = {
    applinks: {
      apps: [],
      details: [
        {
          appID: 'teamId.bundleId',
          paths: ['*']
        }
      ]
    }
  };
  res.set('Content-Type', 'text/html');
  res.send(JSON.stringify(data));
});
```
 - 然后APP安装后首次打开，如果Associated Domain配置了的话，就会去请求app-support.test.com/apple-app-site-association。系统会根据返回的teamId,bundleId,paths知道当打开app-support.test.com下的哪些路径的时候唤醒对应的app，比如paths=*的话，就是打开app-support.test.com下的任意路径都会唤醒app
 
 - app那边会收到对应的路径，然后要根据path写逻辑跳转到对应的功能
 
如何验证配置成功 - 在备忘录中输入配置好的链接，直接点开这个链接(https://app-support.test.com)，配置好的话会直接跳到app， 或者长按，弹出菜单中会提示在xxx中打开 - 在safari中

*常见问题*

- 微信等几个App还是给屏蔽了
- 从9.3.X改版之后，通用链接不支持域内跳转了，跳转前后的两个domain必须是不同的，否则只会safari打开。比如知乎的网站地址是https://www.zhihu.com，而universal link的地址是oia.zhihu.com
- 服务器上apple-app-site-association的更新不会让iOS本地的apple-app-site-association同步更新，即iOS只会在App第一次启动时请求一次，以后除非App更新或重新安装，否则不会在每次打开时请求apple-app-site-association。


**9.Android App Links**
安卓*App Link**的出现原因也是为了优化用户体验，在使用scheme唤醒时会弹出一个对话框提示用户是否打开，并且如果用户勾选了取消之后，可能之后就再也唤醒不了。
安卓App Link的流程和*ios Universal link*的类似，iOS中需要配置的`app-support.test.com/apple-app-site-association`文件在安卓中叫做`app-support.test.com/.well-known/assetlinks.json`，只能放在.well-known下面