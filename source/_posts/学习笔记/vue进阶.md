---
title: vue进阶
date: 2024-01-08 14:21:25
tags:
  - Web
  - JavaScript
categories:
  - 前端开发
  - 培训课
---

# vue 进阶

## 特征一：模块化 => vue-template-compiler （编译态把 template 转换成 render()）

### 插槽 - 面试考察点 => 对比形式

#### 默认插槽

组件外部维护参数与结构，内部安排位置摆放

- 追问 => 默认插槽的实现方式》 => 插槽聚合（渲染在一个地方 顺序渲染）
- 追问 => 多个插槽会以何种形态渲染（合并） => 如何放在不同的地方?

#### 具名插槽

用 name 表示当前身份，从而在组件内部区分

```js
// 父组件
<template v-slot:header>{{header}}</template>
<template #header>{{header}}</template>
// 子组件
<slot name="header"/>
```

- 具名插槽可以在指定位置分开布局 => 原理：name 索引了一段单个解析的命名空间，node 独立由这个单个解析空间进行渲染
- 追问 => 以 node 渲染为单位 => 混合式传参？

#### 作用域插槽

```js
// 父组件
<template slot="content" slot-scope="{slotProps}">{{slotProps}} - {{others}}</template>
// 子组件
<slot name="content" :slotProps={{slotProps}}/>
data(){
  return{
    slotProps:'slot props'
  }
}
```

外部可以做结构勾勒和参数合并，内部也可以提供参数混合

- 父子参数共同向 slot 传递

### 模板的二次加工

1. watch | computed => 配置里声明和书写
2. 其余方法：  
   a. 函数 - 过滤器 | 独立管道符 => 管道符和函数有什么区别？| 管道符能拿到实例嘛？ (**不能！**)  
   b. v-html => 递归调用渲染 node => 安全性风险  
   c. 利用组件形式

```js
// 过滤器
// template
<p>{{money | moneyFilter}}</p>
// script
data(){

},
filters:{
  moneyFilter(param){
    console.log(this)
    return param > 99 ? 99 : param
  }
}
```

### jsx 更自由的 all in js

- 面试题：
  1. 语法糖的实现
  2. jsx 的优点和劣势
     1. vue 编译：（_beforeMount_）template => render() => （_Mounted_）vm.render()
     2. template 编译，带有 dom 渲染优化，性能节约
     3. 直接写 render 函数不受 vue 语法限制，不依赖于 vue 的 api

## 特征二：组件化

```js
Vue.component('component', {
	template: '<h1></h1>',
})
new Vue({
	el: '#app',
})
```

- 1. 抽象复用

- 2. 精简 & 聚合

### 混入 mixin - 逻辑混入

- 1. 应用：核心逻辑 功能的继承
