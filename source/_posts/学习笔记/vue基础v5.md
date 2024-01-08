---

title: vue 基础 v5
abbrlink: 45434
date: 2024-01-06 20:07:53
tags:

- Web
- JavaScript
  categories:
- 前端开发
- 培训课

---

<!-- more -->

- [vue 基础](#vue-基础)
  - [理论](#理论)
    - [面试题：对 MVVM 的了解](#面试题对-mvvm-的了解)
  - [写法](#写法)
    - [vue 如何利用 mvvm 开发?](#vue-如何利用-mvvm-开发)
  - [生命周期](#生命周期)
    - [面试题：vue 的生命周期](#面试题vue-的生命周期)
  - [监听](#监听)
    - [面试题：computed 和 watch](#面试题computed-和-watch)
  - [指令 \& 条件](#指令--条件)
    - [条件](#条件)
    - [v-for \& v-if 在同一节点使用时](#v-for--v-if-在同一节点使用时)
    - [v-model v-once v-text v-html v-bind](#v-model-v-once-v-text-v-html-v-bind)
    - [自定义指令](#自定义指令)
  - [事件 - v-on](#事件---v-on)
    - [修饰符](#修饰符)
    - [事件的设计 - 为何 vue 把事件设计在模板上而不是 js 中](#事件的设计---为何-vue-把事件设计在模板上而不是-js-中)
  - [组件化](#组件化)
    - [一般组件 + 动态组件 =\> 插件](#一般组件--动态组件--插件)

## vue 基础

### 理论

#### 面试题：对 MVVM 的了解

- Web 应用发展史
  1. 语义化模板
  2. MVC - model view controller
  3. MVVM - model view viewModel
     1. 数据本身会通过 model 挂在在 viewModel，vm 会劫持数据并同步至渲染层
     2. 视图层发生外部变化，会同样回调给 vw，返回给 model

### 写法

#### vue 如何利用 mvvm 开发?

数据双向绑定

1. 利用花括号，构筑了数据与 vm 的双向绑定关系 =》 buildTemplate | compile
2. 通过视图绑定监听事件来处理数据 =》v-model === :value @input => 节点处理流程

**buildTemplate =》 render()**

### 生命周期

#### 面试题：vue 的生命周期

创建阶段: beforeCreate => created => beforeMount => mounted

更新阶段: beforeUpdate => updated

销毁阶段: beforeDestroy =》 destroyed

<font color=LightSkyBlue>beforeCreate</font>： new Vue() - 创建实例阶段  
<font color=LightSkyBlue>created</font>: data | props | method | computed - 数据创建

<font color=orange>beforeMount</font>: vDom(虚拟节点) - 数据操作以及虚拟 dom 的变化 但不能涉及 dom  
<font color=orange>mounted</font>: Dom 更新

<font color=CadetBlue>beforeUpdate</font>： vDom - 完成更新，dom 还未更新  
<font color=CadetBlue>updated</font>： dom 完成更新 =》 谨慎做更新数据操作

<font color=Green>beforeDestroy</font>：实例尚未销毁 - 清空 eventBus setTimeOut  
<font color=Green>destroyed</font>：完全销毁

补充：key =》 diff =》 dom diff =》 节点 id

### 监听

#### 面试题：computed 和 watch

相同点：

1. **基于 vue 的依赖收集机制**进行采集
2. 都是被依赖的变化所触发，从而进行处理回调

不同点：

1. 入/出：computed 多入单出，watch 单入多出
2. 性能：computed 存在缓存，不收调用次数的性能损耗；watch 只在监听的值变化时，不包含生成 immediate
3. computed 关注结果，watch 关注过程

问：computed 缓存和响应式如何实现的?

完整过程：

1. 流程：new Vue() => 初始化 computed(initState) => createComputedGetter(key) => mount
2. 劫持：getter 属性变化区分是否是最新状态 dirty
3. target depend <==> 原值和依赖之间的关系链

### 指令 & 条件

#### 条件

v-if | v-show
v-else | v-else-if

v-for

#### v-for & v-if 在同一节点使用时

vue2.x v-for 会优先作用
vue3.x v-if 总是优先于 v-for

#### v-model v-once v-text v-html v-bind

#### 自定义指令

### 事件 - v-on

#### 修饰符

.stop .prevent .once .capture .self .passive

#### 事件的设计 - 为何 vue 把事件设计在模板上而不是 js 中

1. 模板定位视图绑定的触发源 + 触发源寻找触发事件的逻辑 —— 方便定位
2. js 与视图绑定解耦 —— 更便于测试隔离
3. vm 销毁，自动解绑事件 —— 便于回收

### 组件化

#### 一般组件 + 动态组件 => 插件
