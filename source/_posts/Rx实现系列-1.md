---
title: RX实现系列1
date: 2019-03-18 14:00:00
tags:
    - javascript
    - RxJs
---

### 本系列将一步步实现简化版的RxJS

`RxJS`在我的观念里是一个有`流(streams)`式操作的观察者模型。
我们将一步步通过简单的demo实现一个简化版的`RxJS`，没有Rx使用经验的人应该也看的懂

#### 目标 - 实现如下功能

```js
const compony$ = new Observable((observer) => {
  let count = 0
  const timer = setInterval(() => {
    console.log('鲜奶公司发货')
    observer.next(++count);
  }, 1000);
  return () => clearInterval(timer)
})

compony$.pipe(
  map(x => x + 1),
  filter(x => x / 2 === 0)
)

const xiaoming = (count) => console.log(`小明收到${count}瓶奶`)

const unsub = compony$.subscribe((xiaoming)

setTimeOut(() => unsub(), 30000);

```

先来解释下上面名词的含义, `compony$` 一个 `Observable - 可订阅（观察）对象`，负责在有顾客 `xiaoming - 订阅者（观察者)` 发出订阅动作之后，每隔一段时间发出一瓶奶，每天这个小明收到几瓶奶，也是经过一些处理的，也就是`pipe`中的一些操作`operator`。在30天取消订阅。

本例引用自[Yard](http://www.yardwill.com/detail/%E4%BB%8E%E4%B8%80%E4%B8%AA%E7%AE%80%E5%8D%95%E7%9A%84rxjs-demo%E6%9D%A5%E7%9C%8Brxjs%E9%83%A8%E5%88%86%E6%BA%90%E7%A0%81)

#### 第一步
*首先来实现一个`Observable`类，我们可以通过这个对象注册一个`可观测对象- Observable$`*

```js
class Observable {
  constructor(subscribe) {
    if (subscribe) {
      this._subscribe = subscribe
    }
  }
}
```

实际使用中，注册的方式是传入一个函数。
这个函数要具备的功能是：
- 接受一个`observer`观察者，能给`observer`发出值
- 返回一个取消订阅，也就是取消发出值的方法

这就是那个函数：
```js
(observer) => {
  let count = 0
  const timer = setInterval(() => {
    console.log('鲜奶公司发货')
    observer.next(++count);
  }, 1000);
  return () => clearInterval(timer)
}
```

#### 第二步
*这个`Observable`中有一个`subscribe`方法，这个方法的作用是接受一个`observer`，进行格式化处理之后，将这个`observer`传给`Observable$`(即订阅动作)，`observer`开始接受`Observable$`发出的值*。

*触发订阅动作的时候要返回注册函数提供的解绑方法，以供取消订阅使用*

```js
const noon = () => {}
const toSubScriber = (observerOrNext, error, complete) => {
  return {
    next: observerOrNext ? observerOrNext : noon,
    error: error ? error : noon,
    complete: complete ? complete : noon,
  }
}

class Observable {
  constructor(subscribe) {
    if (subscribe) {
      this._subscribe = subscribe
    }
  }

  subscribe(observerOrNext, error, complete) {
    const subscription = toSubScriber(observerOrNext, error, complete)
    const unsub = this._subscribe(subscription)
    return unsub
  }
}
```

到这里我们已经实现了一个很简单的观察者模型，让我们来试用下吧!

```js
const compony$ = new Observable((observer) => {
  let count = 0
  const timer = setInterval(() => {
    console.log('鲜奶公司发货')
    observer.next(++count);
  }, 1000);
  return () => {
    console.log('取消订阅');
    clearInterval(timer)
  }
});

const xiaoming = (i) => console.log(`小明收到${i}瓶奶`)

const unsub = compony$.subscribe(xiaoming);

setTimeout(() => unsub(), 3000);
```

执行效果：


### 第三步

以上我们已经实现了最基础的订阅效果。
接下来想，如果小明只想在双数日送奶，并且每天送两瓶奶，要如何去做。

我们可以设想出以下执行逻辑。

```js
compony$
  .filter((i) => !(i % 2))
  .map((i) => i * 2)

const xiaoming = (i) => console.log(`小明收到${i}瓶奶`)

const unsub = compony$.subscribe(xiaoming);
```

上面的链式写法与我们常见的`Promise.then`类似，但略有差异
`Promise`中的`then`获取上一步结果然后执行逻辑的同时也返回了一个`Promise`,所以可以无限调用

`Observable`中的这些操作符`filter`,`map`,(称作`operators`)，它接收上级`Observable1`，返回一个新的`Observable2`，`Observable2`在被订阅时，会先触发`Observable1`的订阅，并对`Observable1`发出的值进行处理。

注意到,`then`接受的是上一步发出的值，`operator`接受的是整个`Observable`，这也是`Observable`在被订阅之后才发出值的原因。

这特别像`Redux`中间件的洋葱圈模型，如下所示：

<img src="https://images.tuyacn.com//smart/connect-scheme/156231608830ca2b433c5.png" width="500" height="auto" />

实现如下
```js
const map = (action) => {
  return (prevObservable) =>  new Observable((observer) => {
    const sink = prevObservable.subscribe((res) => observer.next((action(res))))
    return sink
  })
}
const filter = (action) => {
  return (prevObservable) =>  new Observable((observer) => {
    const sink = prevObservable.subscribe((res) => {
      const result = action(res)
      if (result) {
        return  observer.next(res)
      }
     return null
    })
    return sink
  })
}
```

如果像上面这样子的定义的话，我们调用起来是丑陋的
也是很难看懂的：
```js
map(i => i * 2)(filter(i => i % 2)(compony$))
```

`Rxjs`官方提供了一个`pipe`的方式，让我们可以按照如下的方式调用`operator`，如下

```js
compony$.pipe(
  filter(i => i % 2),
  map(i => i * 2)
)

compony$.subscribe(xiaoming)
```

接下来我们实现这个`pipe`方法，js中有个方法叫`reduce`，能够方便的实现我们的想法，没有过的同学[戳这里](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Global_Objects/Array/Reduce)

```js
const pipe = (source, ...fns) {
  return fns.reduce((state, fn) => fn(state), initialValue);
}
```

这样我们就可以以下方式调用了：

```js
const unsub = pipe(compony$, filter(x => x % 2), operator_map(x => x + 1)).subscribe(xiaoming)
```

但是这样我们的`pipe`方法还是独立的，接下来要把`pipe`挂到`Observable`下:

```js
class Observable {
  constructor(subscribe) {
    if (subscribe) {
      this._subscribe = subscribe
    }
  }

  subscribe(observerOrNext, error, complete) {
    const subscription = toSubScriber(observerOrNext, error, complete)
    const unsub = this._subscribe(subscription)
    return unsub
  }

  pipe(...fns) {
    return fns.reduce((state, fn) => fn(state), this);
  }
}
```

这样我们就实现了官方的`pipe`。
下面贴上完整代码，实际没几行：
```js
const noon = () => {}
const toSubScriber = (observerOrNext, error, complete) => {
  return {
    next: observerOrNext ? observerOrNext : noon,
    error: error ? error : noon,
    complete: complete ? complete : noon,
  }
}

class Observable {
  constructor(subscribe) {
    if (subscribe) {
      this._subscribe = subscribe
    }
  }

  subscribe(observerOrNext, error, complete) {
    const subscription = toSubScriber(observerOrNext, error, complete)
    const unsub = this._subscribe(subscription)
    return unsub
  }

  pipe(...fns) {
    return fns.reduce((state, fn) => fn(state), this);
  }
}

const map = (action) => {
  return (prevObservable) =>  new Observable((observer) => {
    const sink = prevObservable.subscribe((res) => observer.next((action(res))))
    return sink
  })
}

const filter = (action) => {
  return (prevObservable) =>  new Observable((observer) => {
    const sink = prevObservable.subscribe((res) => {
      const result = action(res)
      if (result) {
        return  observer.next(res)
      }
     return null
    })
    return sink
  })
}

// 调用

const compony$ = new Observable((observer) => {
  let count = 0
  const timer = setInterval(() => {
    console.log('鲜奶公司发货')
    observer.next(++count);
  }, 1000);
  return () => {
    console.log('取消订阅');
    clearInterval(timer)
  }
});

const xiaoming = count => console.log(`小明收到${count}瓶奶`)

const unsub = compony$.pipe(
  filter(x => x % 2),
  operator_map(x => x + 1),
).subscribe(observer_xiaoming)

setTimeout(() => unsub(), 40000)
```

没有依赖，各位可以自己copy看看执行结果。

以上为RX实现系列1, 下节讲Rx的`单播`和`多播`以及`hot`and`cold`。
