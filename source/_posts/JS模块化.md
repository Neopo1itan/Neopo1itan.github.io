---
title: JS模块化
categories:
  - JS
tags:
  - Web
  - JavaScript
abbrlink: 58364
date: 2024-01-05 16:55:59
---

# JS 模块化

本节课是基础和工程化之间的**模块化**  
基础 => _模块化_ => 工程化

<!-- more-->

- [JS 模块化](#js-模块化)
  - [1. 历史](#1-历史)
    - [背景](#背景)
    - [幼年期：无模块化](#幼年期无模块化)
    - [成长期：模块化的雏形 - IIFE(语法侧的处理)](#成长期模块化的雏形---iife语法侧的处理)
      - [作用域的把控](#作用域的把控)
    - [成熟期](#成熟期)
      - [Cjs - commonjs](#cjs---commonjs)
      - [AMD](#amd)
      - [CMD 规范](#cmd-规范)
      - [完全体 ESM =\> ES Module](#完全体-esm--es-module)
    - [函数式编程](#函数式编程)

## 1. 历史

### 背景

JS 最开始定位：简单页面设计支撑 —— 页面的动画+表单提交  
并无模块化 or 命名空间基础

JS 的模块化需求日益增长

### 幼年期：无模块化

1. 开始需要页面加载不同的 js 库：动画库、表单库、格式化工具
2. 多种 js 文件被分在不同的文件中
3. 不同的文件又被同一个模板引用

```js
// index.html
<script src='tools.js'></script>
<script src='map.js'></script>
// 主
<script src='main.js'></script>
```

- 追问  
  script 标签的两个参数- async & defer

```js
<script src='tools.js' type='text/javascript' async></script>
```

> 总结：  
> **普通**：解析到标签，立刻 pending，并且下载执行  
> **defer**：解析到标签，开始异步下载，继续往后进行，完成之后开始执行  
> **async**：解析到标签，开始异步下载，下载完成之后立刻执行并且阻塞往后解析，执行完成后再继续向下

问题导向：浏览器渲染原理、同步异步原理、模块化加载原理

问题出现

- 污染全局作用域 => 不利于大型项目的开发与多人团队的构建

### 成长期：模块化的雏形 - IIFE(语法侧的处理)

#### 作用域的把控

举例子：

```js
// 全局变量
let count = 0

// 代码块01
const increase = () => ++count

// 代码块02
const reset = () => {
	count = 0
}

increase()
reset()
```

利用函数的独立作用域

```js
;(() => {
	let count = 0
	// ...
})()
```

**定义的函数 + 立即执行 => 独立的空间**  
初步实现了一个**基础模块**

尝试定义一个简单的模块

```js
cosnt module =(()=>{
  let count =0;
  return{
    increase:()=>++count;
    reset:()=>{
      count =0;
    }
  }
})();
module.increase();
module.reset();

// 追问：有外部依赖的情况如何优化处理
const iifeModule = ((dependencyModule,dependencyModule2)=>{
  let count =0;
  // dependencyModule,dependencyModule2..
  return{
    increase:()=>++count;
    reset:()=>{
      count =0;
  }
})(dependencyModule,dependencyModule2);

// 揭示模式
const iifeModule = ((dependencyModule,dependencyModule2)=>{
  let count =0;
  // dependencyModule,dependencyModule2..
  // 代码块01
const increase = () => ++count;

// 代码块02
const reset = () => {
    count = 0;
}

  return{
    increase,
    reset
})(dependencyModule,dependencyModule2);
// 返回的是能力 = 使用方的传参 + 本身的逻辑能力 + 依赖能力
```

- 面试方向
- 1. 深入模块化实现
- 2. 转向框架 jquery vue react 模块组件的实现细节，以及框架原理特征
- 3. 转向设计模式 - 注重模块化的设计

### 成熟期

#### Cjs - commonjs

> node.js 指定的标准  
> 特征：

- 通过 module + export 去外暴露接口
- 通过 require 去调用其他模块

模块的
dep.js

```js
// 引入部分
const dependencyModule=require('..dependencyModule')
// 核心逻辑
let count =0;
  // dependencyModule,dependencyModule2..
  // 代码块01
const increase = () => ++count;

// 代码块02
const reset = () => {
    count = 0;
}
// 暴露接口部分
//type1
export.increase = increase;
export.reset = reset;

// type2
module.exports={
  increase,
  reset
}

```

// 引入并使用

```js
const { increase, reset } = require('dep.js')
increase()
reset()
```

> - 优点：  
>   Cjs 服务侧的角度解决了依赖全局污染的问题 + 完全在写法上也实现了主观感受上的模块化
> - 缺点：  
>   针对服务端 => 异步

#### AMD

> 通过异步加载 + 允许定制回调函数  
> 经典的实现框架：**require.js**

新增定义方式

```js
// 通过define定义一个模块，然后用require去加载
define(id, [depends], callback)
requiere([module], callback)
```

```js
define('amdModule', ['dependencyModule1', 'dependencyModule2'], (dependencyModule1, dependencyModule2) => {
	// 业务逻辑
	let count = 0
	// dependencyModule,dependencyModule2..
	// 代码块01
	const increase = () => ++count

	// 代码块02
	const reset = () => {
		count = 0
	}
})
```

```js
require(['amdModule'], (amdModule) => {
	amdModule.increase()
})
```

**面试题**

```js
define('amdModule', [], (require) => {
	const dependencyModule1 = require('./dependencyModule1')
	const dependencyModule2 = require('./dependencyModule2')
	// 逻辑...
})
```

**面试**：区分 Cjs 和 AMD？手写兼容 Cjs 和 AMD 的模块

**UMD**  
优点：解决了服务、客户端异步动态依赖问题  
缺点：引入成本，未考虑按需加载

```js
(define("amdModule", ["dependencyModule1", "dependencyModule2"], (
  dependencyModule1,
  dependencyModule2
) => {
  // 业务逻辑
  let count = 0;
  // dependencyModule,dependencyModule2..
  // 代码块01
  const increase = () => ++count;

  // 代码块02
  const reset = () => {
    count = 0;
  };
  export.increase =increase;
  export.reset = reset;
  return{
    increase,
    reset
  }
}))(
  // 目标：一次去定位区分Cjs和AMD
  // 1. Cjs factory
  // 2. module module.exports
  // 3. define
  typeof module === 'Object' && module.exports && typeof define !== 'function' ? //是Cjs
              factory => module.exports => factory(require,exports,module)
            : //是AMD
              define
)
```

#### CMD 规范

> 按需加载  
> 主要应用框架：sea.js

```js
// 依赖就近
define('module', (require, exports, module) => {
	let $ = require('map')
	// ...代码块1
	if (xxx) {
		return
	}

	let depends2 = require('./dependencyModule2')
	// 代码块2
})
```

**优点**:

- 按需加载，依赖就近

**缺点**：

- 1.依赖打包
- 2.扩大了模块内体积

#### 完全体 ESM => ES Module

> **走进新时代**  
> 新增定义：  
> 引入 - import  
> 导出 - export

```js
// 引入区域
import dependencyModule1 from './dependencyModule1'

// 逻辑处理
// ....

export default {
	increase,
	reset,
}
```

追问：  
处理动态异步依赖

```js
// es方式
const moduleDependency = async () => {
	// ..模块处理
	return await dependencyModule1.init()
}

//原生
import('./dependencyModule.js').then((dynamicEsModule) => {
	dynamicEsModule.init()
})
```

优点

- 通过一种最统一的形态整合了所有 js 的模块化

### 函数式编程

```js
const fetch = ajax(method, url, params)

const fetch = ajax.get(url)
// ajax.post(url)

const request = fetch(params)
// == ajax.get(url)(params)

const fetch = ajax(method)(url)(params)

send(request, fetch)
```
