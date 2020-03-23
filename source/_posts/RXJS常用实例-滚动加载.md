
title: RXJS+React实现滚动加载
date: 2019-08-11 11:00:00
tags:
    - RxJs
---

## RXJS+React实现滚动加载

不一定要*React*，以此为例
以代码注释讲解

```js
import React from 'react'

import { from } from 'rxjs/internal/observable/from'
import { fromEvent } from 'rxjs/internal/observable/fromEvent'
import { exhaustMap } from 'rxjs/internal/operators/exhaustMap'
import { map } from 'rxjs/internal/operators/map'
import { tap } from 'rxjs/internal/operators/tap'
import { filter } from 'rxjs/internal/operators/filter'
import { pairwise } from 'rxjs/internal/operators/pairwise'

class Index extends React.Component<IProps, any> {

  private wrapperDom: any

  public componentDidMount() {
    // 初始化
    const obs = this.initialScrollObservable()
    // 开始订阅
    obs.subscribe()
  }

  private concatProducts = async () => await fetch(...)

  private initialScrollObservable = () => {
    // 使用fromEvent创建一个Observable
    return fromEvent(this.wrapperDom, 'scroll').pipe(
      // 获取滚动位置
      map((e: any) => e.target.scrollTop),
      // 记录相邻两次的滚动位置, 抛出[pos1, pos2]
      pairwise(),
      // 条件过滤
      filter((positions: number[]) => {
        // 判断是否向下滑动
        const isScrollDown = positions[0] < positions[1]
        // 判断距离滚动容器底部还有200px的距离
        const positionMeet =
          positions[1] +
            this.wrapperDom.clientHeight +
            200 >=
          this.wrapperDom.scrollHeight
        // 同时返回这两个条件才通过筛选
        return isScrollDown && positionMeet
      }),
      // exhaustMap的作用是在一次加载数据的Observable完成之后，才能再次加载
      // from根据一个promise返回一个Observable
      exhaustMap(() => from(this.concatProducts())),
    )
  }

  render() {
    return (
      // 触发滚动事件的dom
      <div ref={(d) => this.wrapperDom = d}>
        ....
      </div>
    )
  }
}

export default Index


```