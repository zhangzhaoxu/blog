title: RXJS+React 实现Slider
date: 2019-08-11 11:00:00
tags:
    - RxJs
---

### RXJS+React 实现Slider

不多bb，上代码

```js
import React from 'react'
import styles from './index.scss'

import { fromEvent } from 'rxjs/internal/observable/fromEvent'
import { mergeMap } from 'rxjs/internal/operators/mergeMap'
import { switchMap } from 'rxjs/internal/operators/switchMap'
import { takeUntil } from 'rxjs/internal/operators/takeUntil'
import { scan } from 'rxjs/internal/operators/scan'
import { map } from 'rxjs/internal/operators/map'
import { filter } from 'rxjs/internal/operators/filter'
import { pairwise } from 'rxjs/internal/operators/pairwise'

const setTransition = (dom) => {
  dom.style.transition = `all 0.3s ease`
  setTimeout(() => (dom.style.transition = ''), 300)
}

const getPos = (e: TouchEvent) => {
  const touch = e.touches[0] || e.changedTouches[0]
  return [Number(touch.pageX), Number(touch.pageY)]
}

const getX = (e: TouchEvent) => {
  const touch = e.touches[0] || e.changedTouches[0]
  return Number(touch.pageX)
}

const judgeHorizontalOrVerticality = (downPos, firstMovePos) => {
  return (
    Math.abs(firstMovePos[0] - downPos[0]) >
    Math.abs(firstMovePos[1] - downPos[1])
  )
}

interface IProps {
  imgList: string[]
}

class Index extends React.Component<IProps, any> {

  private wrapperDom: any           // 最外层容器dom，宽度固定一屏幕
  private imgWrapperWidth: string   // 图片容器的宽度，宽度动态计算
  private canHorizontal: boolean    // 是否允许上下滑动
  private translateX: number = 0    // 当前x轴位移的距离
  private wWidth: number            // 屏幕的宽度，也为容器dom的宽度
  private translateXWidth: number   // 可以在x轴上滑动的最大距离
  private pageCount: number         // 图片数量

  constructor(props) {
    super(props)
    this.state = {
      currentIndex: 1,
    }

    this.pageCount = props.imgList.length
    this.imgWrapperWidth = `${this.pageCount * 3.75}rem`
  }

  public componentDidMount() {
    this.wWidth = document.body.clientWidth
    // 记录可以滑动的最大距离，为图片容器的宽度减去一屏幕的宽度
    this.translateXWidth = this.wrapperDom.clientWidth - this.wWidth
    // 初始化observable并订阅
    this.initialObservable()
  }

  // 设置图片容器translateX
  private setTranslateX = (endTransX) => {
    // 滑动到最右的情况
    if (endTransX < -this.translateXWidth) {
      endTransX = -this.translateXWidth
    }
    // 滑动到最左的情况
    if (endTransX > 0) {
      endTransX = 0
    }
    // 滑动
    this.wrapperDom.style.transform = `translate(${endTransX}px, 0)`
    // 设值
    this.translateX = endTransX
  }

  private handleTouchmove = (pos: number[]) => {
    const distance = pos[1] - pos[0]
    const endTransX = this.translateX + distance
    this.setTranslateX(endTransX)
  }

  // 判断滑动一段距离后是否加载下一页
  private handleChangeIndex = (pos) => {
    const { currentIndex } = this.state
    const distance = pos.endX - pos.startX
    // 向右， 距离五分之一屏幕，且不为最后一张
    if (distance < 0 &&
      distance < -(this.wWidth / 5) &&
      currentIndex + 1 <= this.pageCount
    ) {
      // 需要设值动画transition, 并在执行之后清楚掉，至于为什么，试下不清
      setTransition(this.wrapperDom)
      this.setTranslateX(currentIndex * -this.wWidth)
      this.setState({ currentIndex: currentIndex + 1 })
    } else if (
      // 向左, 距离五分之一屏幕, 且不为第一张
      distance > 0 &&
      distance > this.wWidth / 5 &&
      currentIndex > 1
    ) {
      setTransition(this.wrapperDom)
      this.setTranslateX((currentIndex - 2) * -this.wWidth)
      this.setState({ currentIndex: currentIndex - 1 })
    } else {
      // 归位
      setTransition(this.wrapperDom)
      this.setTranslateX((currentIndex - 1) * -this.wWidth)
    }
  }

  private initialObservable = () => {
    // touch start Observable
    const start$ = fromEvent(this.wrapperDom, 'touchstart').pipe(map((e: TouchEvent) => getPos(e)))
    // touch move Observable
    const move$ = fromEvent(this.wrapperDom, 'touchmove')
    // touch end Observable
    const end$ = fromEvent(this.wrapperDom, 'touchend').pipe(map((e: TouchEvent) => getPos(e)))

    // move同时滑动
    start$.pipe(
      mergeMap((startPos) => {
        return move$.pipe(
          // 第一次move判定左右还是上下，如果是上下，则禁止左右滑动
          // scan 会缓存上一次计算的值，并在下一次的时候传入第一个参数。首次第一个参数是undefined
          scan((acc: [boolean, TouchEvent], currentMouseEvent: TouchEvent, index) => {
            this.canHorizontal = acc[0]
            if (index === 0) {
              const currentPos = getPos(currentMouseEvent)
              this.canHorizontal = judgeHorizontalOrVerticality(startPos, currentPos)
            }
            return [this.canHorizontal, currentMouseEvent]
          }),
          filter((arr: any) => arr[0]),
          map((acc: [boolean, TouchEvent]) => {
            const canMoveEvent = acc[1]
            // 通过判定已经是左右滑动了，便禁止掉上下滑动，防止左上，左下，右上，右下放下滑动引起效果不好
            canMoveEvent.stopPropagation()
            canMoveEvent.preventDefault()
            return getX(canMoveEvent)
          }),
          // pairwise 会缓存最近两次的值，pos1, pos2
          pairwise(),
          // 在滑动结束的时候清楚掉所有值
          takeUntil(end$),
        )
      }),
      // 开始订阅
    ).subscribe((pos) => {
      this.handleTouchmove(pos)
    })

    // 结束后时候换页
    start$.pipe(
      switchMap((startPos) => {
        return end$.pipe(
          map((endPos) => ({
            startX: startPos[0],
            endX: endPos[0],
          })),
        )
      }),
    ).subscribe((pos) => {
      this.canHorizontal && this.handleChangeIndex(pos)
      this.canHorizontal = false
    })
  }

  public render() {
    const { imgList } = this.props
    const { currentIndex } = this.state
    return (
      // 滑动的父容器，一屏幕宽
      <div style={{ width: '3.75rem' }}>
        // 所有图片并排，图片容器宽度喂 3.75 * 图片张数
        <div
          ref={(dom) => this.wrapperDom = dom}
          style={{ width: this.imgWrapperWidth }}
        >
          {imgList.map((url, index) => (<img src={url} key={index} />))}
        </div>
      </div>
    )
  }
}

export default Index

```
