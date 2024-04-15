<!--
 * @Descripttion:
 * @version:
 * @Author: 雷宇琦
 * @Date: 2024-04-15 15:42:55
 * @LastEditors: 雷宇琦
 * @LastEditTime: 2024-04-15 17:24:05
-->

---

title: JS 性能优化
abbrlink: 2317
date: 2024-04-15 15:32:12
categories:

- JS
  tags:
- Web
- JavaScript

---

## 性能优化进阶

### Navigation Timing API

**面试**:在代码执行之前，浏览器加载页面发生了什么？  
=> 浏览器原理  
=> 广度：DOM 渲染、存储...

**打印当前页面耗时:**

```js
// index.html
<script>
  javascript:(()=>{
    const perfData = window.perfomance.timing
    cosnt pageLoadTime = perData.loadEventEnd - perData.navigationStart // 时间戳之差

    console.log('当前页面加载耗时:',pageLoadTime,'ms')
  })
</script>
```

<!-- more -->

> _强缓存_：不发请求 -> expires cache-control  
> _协商缓存_：发 -> Last-Modified & - Since | ETag & If-None-Match

### Core Web Vitals - 网页核心性能指标

- Google 提出的衡量指标
- 可量化的，反应真实主管体验：加载、交互性、稳定性

#### Largest Contentful Paint (LCP)

<font color="#FFAACC">**衡量装载性能**</font>

- 前 2.5s 内完成最大内容渲染
  - a.包括哪些内容？
    - 【img】元素
    - 【svg】元素
    - 【video】元素
    - 通过 url()函数加载的背景图片元素
    - 包含文本节点或者其他内联文本元素子集的块级元素
  - b.LCP 低下的原因
    - 服务器响应慢
    - 阻断 JS 和 CSS 的渲染 => JS DOM 渲染是互斥的
    - 资源加载未优化
    - 客户端渲染机器性能影响 => 提升页面脚本性能

#### First Input Delay (FID)

<font color="#FFAACC">**衡量交互性**</font>

- 页面首次输入延迟小于 100ms
  - a. js 执行过多
    - 避免非必要的 js 后置执行
    - 尽量减少 polyfill
  - b. 耗时任务过多
    - 阻塞主线程 50ms 以上 => 长任务
    - 拆分 & 降级
  - c. 单线程导致的队列阻塞
    - worker

MS

```js
// main.js
// 新增worker
const myWorker = new Worker('worker.js')

// 主从通信
myWorker.postMessage('hello')
myWorker.onmessage = function (e) {
	// ...
}

// worker.js
// 数组遍历 + 读取 + js计算
self.onmessage = () => {
	self.postMessage(res)
}
```

#### Cumulative Layout Shift(CLS)

<font color="#FFAACC">**衡量视觉的稳定性**</font>

- 布局的移动发生在两个相邻帧之间，页面 CLS 小于 0.1
  - a 不适用无尺寸的元素
    - 图片、视频、头像...
  - b 减少内容的插入 => 减少影响布局元素的出现
  - c 控制字体

### 性能优化体系

a) 埋点上报 => 点到点 + 信息采集 + 主动上报  
b) 数据处理 => 数据计算 + 阈值设置 + 数据分类  
c) 可视化展示  
d) 告警处理  
e) 预警体系
