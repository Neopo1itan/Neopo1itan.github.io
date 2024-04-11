---
title: 浏览器 Browser
abbrlink: 15523
date: 2024-03-25 14:48:56
tags:
  - Web
---

## 概念

JavaScript 在浏览器下一般三部分组成：  
ECMAscript DOM BOM

**W3C** 是非标准化组织，制定浏览器规范

**ECMAscript**：是一种标准，用来标准化 JavaScript 语言，es6、es7 都是其标准化的产物。在浏览器中以 V8，JSCore 等引擎解析。

**MDN**：Mozilla Developer Network 规范文档

<!-- more -->

- [概念](#概念)
- [常见 BOM 对象](#常见-bom-对象)
- [事件模型](#事件模型)
- [事件委托](#事件委托)
- [实现懒加载](#实现懒加载)
	- [使用 scroll event 和 getBoundingClientRect 实现](#使用-scroll-event-和-getboundingclientrect-实现)
	- [使用 IntersectionObserver 实现](#使用-intersectionobserver-实现)
- [浏览器请求](#浏览器请求)
	- [XHR](#xhr)
	- [fetch](#fetch)
		- [1.默认不带 cookie](#1默认不带-cookie)
		- [2.错误不会 reject](#2错误不会-reject)
		- [3.不支持超时设置](#3不支持超时设置)
		- [4.中止 fetch（借用 AbortController）](#4中止-fetch借用-abortcontroller)
- [Http 缓存](#http-缓存)
	- [强制缓存](#强制缓存)
	- [协商缓存](#协商缓存)
	- [Etag 实现](#etag-实现)
	- [优劣](#优劣)

## 常见 BOM 对象

**Navigator**：浏览器代码，名称，操作系统，是否在线等

**location**：hash，hostname 主机路径，port 端口，origin 协议主机端口；支持 reload、replace 等方法。

**screen**：pixelDepth 等

**History**：back() forward()等跨网页跳转 pushState()页面不刷新

## 事件模型

```html
<div id="app">
	<p id="dom">Click!</p>
</div>
```

```js
//冒泡:p -> div -> body -> html -> document
//捕获:document -> html -> body -> div -> p
el.addEventListener(event.function, useCapture)

//阻止事件冒泡传播
event.stopPropagation()
//阻止默认事件传播
event.preventDefault()
//相同节点绑定多个同类型事件，阻止
event.stopImmediatePropagation()
```

## 事件委托

利用冒泡实现事件代理

```html
<ul>
	<li></li>
	<li></li>
	<li></li>
</ul>
// 将事件绑定在ul上 点击某个li代理捕获到事件
```

## 实现懒加载

### 使用 scroll event 和 getBoundingClientRect 实现

> 将 img 的 src 属性写入 data-src，监听页面滚动事件，当图片可以看见时（img 元素顶部距离视窗顶部距离小于视窗高度），则加载
> data-src 中的图片路径。

```html
<img data-src="./xxx.png" alt />
<img data-src="./xxx.png" alt />

<script>
	const imgs = document.querySelectAll('img')
	window.addEventLisener('scroll', () => {
		imgs.forEach((img) => {
			const imgTop = img.getBoundingClientRect().top
			if (imgTop < window.innerHeight) {
				const data_src = img.getAttribute('data-src')
				img.setAttribute('src', data_src)
			}
		})
	})
</script>
```

### 使用 IntersectionObserver 实现

> **IntersectionObserver**是浏览器提供的函数，交叉观察，当目标元素和可视窗口出现交叉区域时，触发事件会触发两次，目标元看见或看不见都会触发

## 浏览器请求

### XHR

```js
// 实例化
const xhr = new XMLHttpRequest()
// 初始化链接
xhr.open(method, url, async)
// 发起请求
xhr.send(data)
// 接收统计
xhr.readyStatus //0-尚未调用open,1-已经open,2-已经send,3-已接收请求,4-请求以完成

// 接收回调
xhr.onreadystatechange = () => {
	if (xhr.readyStatus === 4) {
		if ((xhr.status >= 200 && xhr.status < 300) || xhr.status == 304) {
			// 请求成功
		}
	}
}

// 设置超时
xhr.timeout = 1000
xhr.ontimeout = () => {}
```

### fetch

#### 1.默认不带 cookie

```js
fetch('http://domain/service', {
	method: 'POST',
	credentials: 'same-origin', // include可以通榆发送，'same-origin'只能同域发送
})
```

#### 2.错误不会 reject

#### 3.不支持超时设置

#### 4.中止 fetch（借用 AbortController）

## Http 缓存

> 缓存的原理是首次请求之后保存一份请求资源的**响应副本**，如果判断缓存命中则拦截请求，将之前存储的**响应副本**返回给用户，从而避免重新发起资源请求

HTTP 缓存可细分为**强制缓存**和**协商缓存**，二者最大区别是是否需要向服务器**询问**从而决定是否发起请求。
[![OmRj36.md.png](https://ooo.0x0.ooo/2024/04/11/OmRj36.md.png)](https://img.tg/image/OmRj36)

### 强制缓存

无脑按时间判断是否需要更新，不判断服务器端文件是否更新

### 协商缓存

基于 last-modified 实现

1. 首先在服务器端读出修改时间
2. 将读出来的时间赋给响应头的 last-modified 字段
3. 最后设置 Cache-control：no-cache

### Etag 实现

hash 实现

1. 第一次请求时候，服务器端将要返回给客户端的数据通过 Etag 模块进行 hash 生成字符串，这个字符串类似于*文件指纹*
2. 第二次请求是，客户端从缓存读取上一次返回的 Etag，并赋给请求头 if-None-Match 字段
3. 服务器端监测 if-None-Match 字段的值与第一步计算的是否一致，一致则返回 304
4. 如果不一致则返回 etag 标头和 Cache-Control：no-cache

### 优劣

精确度 etag 高  
耗时 last-modified 更快  
服务器优先选择 etag
