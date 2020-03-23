title: RXJS 时间验证码功能
date: 2019-08-11 11:00:00
tags:
    - RxJs
---

### RXJS 时间验证码功能

不多bb，上代码，这次采用`subject`的写法

```js
import { Subject, from, timer } from 'rxjs'
import { take, filter, exhaustMap, mergeMap } from 'rxjs/operators'

const send$ = new Subject()

const send = async () => {
  await fetch(...)
}

send$.pipe(
  // 一次请求结束前下次没用，防连点
  exhaustMap((phoneNumber) => from(send())),
  // 筛选正确的请求
  filter((res: any) => res.success),
  // 请求成功之后开始倒计时
  mergeMap(() => timer(0, 1000)),
  // 取60次
  take(60),
)

// 开始订阅
this.count$.subscribe((n: number) => {
  // do something
  // 因为是用take，只会执行60次，所以需要在结束后重新订阅
}, () => {}, this.subscribeSubject)

// 发出值
send$.next()
```