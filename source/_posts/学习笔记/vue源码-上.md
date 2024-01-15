---

title: vue 源码(上)
date: 2024-01-15 15:09:23
tags:
- Web
- Vue
  categories:
- 前端开发
- 培训课

---

# 引言

> **面试**：观察者模式 & 发布订阅  
> 观察者模式：(观察者，被观察者) 中心一对多 + 系统单点的灵活和拓展  
> 发布订阅：(发布者，订阅者，发布订阅中心) 调度中心 => 将注册列表*遍历*然后发布给订阅者

view -> listner/binding/处理内容 -> model

> **追问**：要实现这些方式，如何双向绑定

    数据监听器Observe     <----     mvvm
                |                    |
                |                    |
                V                    |
    通知数据变化Dep                   |
                | ↑                  |
                | 添加订阅            |
                V |                  |
    连接双方的桥梁watcher<---   代码生成(指令归纳)
                |          |         |
                |   绑定函数/订阅数据  |
             更新视图       |         |
                |           -------- |
                V                    V
               view   <—更新视图—  compiler

源码 -> 原理 -> 他人源码思路

<!-- more -->

- [引言](#引言)
- [vue2 源码](#vue2-源码)
  - [源码结构](#源码结构)
    - [compiler](#compiler)
    - [core](#core)
    - [platforms](#platforms)
    - [shared](#shared)
    - [types](#types)

# vue2 源码

## 源码结构

### compiler

### core

```js
// index.ts
// 初始化全局入口
initGlobalAPI(VUE)
```

### platforms

### shared

### types
