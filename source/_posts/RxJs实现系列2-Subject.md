title: RxJs实现系列2-Subject
date: 2019-11-06 11:00:00
tags:
    - RxJs
---

### RxJs实现系列2-Subject

根据上期实现的`Observable`来看下这种场景。一个`Observable`多个`Observer`。用代码实现如下

```js
const compony$ = new Observable((observer) => {
  let count = 0
  const timer = setInterval(() => {
    observer.next(++count);
    if (count === 3) {
      clearInterval(timer)
    }
  }, 1000);
  return () => clearInterval(timer)
});

const observer1 = (count) => {
  console.log(`observer1, ${count}`)
}

const observer2 = (count) => {
  console.log(`observer2, ${count}`)
}

compony$.subscribe(observer1)

setTimeout(() => compony$.subscribe(observer2), 2000)

```

实际得到的输出如下：

```
observer1, 1
observer1, 2
observer2, 1
observer1, 3
observer2, 2
observer2, 3
```

我们会发现，当一个`observer`重新订阅后，会*生成*一个新的`Observable`，因为`Observable`实际上就是一个函数，订阅一次执行一次。

我们期望的是，只有一个`Observable`，多个`observer`无论何时订阅，会接受到相同的值。这种处理方式称为组播。

`RxJs`中提供了一个概念叫`Subject`.

*先不说概念，直接上代码*

```js
const noon = () => {}
const toSubScriber = (params = {}) => {
  const { next = noon, error = noon, complete = noon } = params
  return {
    next,
    error,
    complete
  }
}

class Observable {
  constructor(subscribe) {
    if (subscribe) {
      this._subscribe = subscribe.next
    }
  }
  subscribe = (params) => {
    const subscription = toSubScriber(params)
    const unsub = this._subscribe(subscription)
    return unsub
  }
  pipe = (...fns) => {
    return fns.reduce((state, fn) => fn(state), this);
  }
}

class Subject {
  constructor() {
    this.observers = []
  }
  subscribe = (observer) => {
    if (observer) {
      this.observers.push(observer)
    }
  }
  next = (value) => {
    this.observers.forEach(o => o.next(value))
  }
  error = (err) => {
    this.observers.forEach(o => o.error(err))
  }
  complete = (value) => {
    this.observers.forEach(o => o.complete(value))
  }
}
```

从代码上看，Subject是一个有subscribe, next，error，complete的类，它的实例化对象可以被Observable直接订阅。
看下面的用法

```js
const compony$ = new Observable({
  next: (observer) => {
    let count = 0
    const timer = setInterval(() => {
      observer.next(++count);
      if (count === 3) {
        clearInterval(timer)
      }
    }, 1000);
    return () => clearInterval(timer)
  }
});

const subject$ = new Subject()

const observer1 = {
  next: (count) => {
    console.log(`observer1, ${count}`)
  }
}

const observer2 = {
  next: (count) => {
    console.log(`observer2, ${count}`)
  }
}

subject$.subscribe(observer1)
setTimeout(() => subject$.subscribe(observer2), 2000)

compony$.subscribe(subject$)
```

在这个示例中，`Subject`的作用更像一个*中间人*，保存所有的`observer`，然后作为一个`observer`去订阅`company$`，接收到`company$`发出的值后，又把值广播给了所有的`observer`。
在这其中，`Subject`这个中间人，既担任了`Observable`，又担任了`observer`。

根据官方的说明，`Subject`是一个根据观察者模式实现的，可以对多个`observer`通知的类。它可以去订阅`Observable`，又可以`observer`订阅。

总结：
  - `Subject`既是`Observable`又是`Observer`
  - `Subject`可以对保存的`observers`进行广播

由于`Subject`继承了`Observable`，它可以想`Observable`一样对数据进行流式操作。当然这个简单的demo是不行的，嘿嘿
