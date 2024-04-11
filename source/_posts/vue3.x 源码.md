---
title: vue3.x 源码
tags:
  - Web
  - Vue
categories:
  - Vue
abbrlink: 54268
date: 2024-01-16 15:33:05
---

## vue2 存在的问题

- 代码结构：以整体的包为形式存在
- 性能优化的空间：ObjectDefineProperty 对象的方法，要对数组进行操作的话需要再自己封装一层，且所有值都是响应式的(性能损耗)
- 选项式的配置模式：不好维护庞大的项目，可维护性
- 浏览器真的需要老版本吗

## vue3 的问题

- 太多的 **breaking changes** 太多不兼容的内容
- 生态影响
- 发布节奏太快
<!-- more -->
- [vue2 存在的问题](#vue2-存在的问题)
- [vue3 的问题](#vue3-的问题)
- [vue3 的优化](#vue3-的优化)
  - [结构上的优化 - monorepo](#结构上的优化---monorepo)
  - [性能上的优化](#性能上的优化)
  - [编译优化](#编译优化)
  - [数据劫持优化](#数据劫持优化)
- [模板编译](#模板编译)
- [基于 proxy 的响应式](#基于-proxy-的响应式)
- [手写 defineReactive](#手写-definereactive)

## vue3 的优化

### 结构上的优化 - monorepo

原子结构 可独立拆分引用 => 可做业务上的拆分

### 性能上的优化

- 移除了很多使用率低的 api

- **tree-shaking** => 产物打包优化

```js
import components from 'components'
//components.input

import { input } from 'components'
import { ref, computed, watch } from 'vue'
```

### 编译优化

compile 阶段对静态的模板进行分析 => 分析树 <= PatchFlag

### 数据劫持优化

**vue2.x**  
_object.defineProperty_

1. 无法检测对象属性的增加和删除 => $set $delete
2. 数组 => push pop...
3. 层级较深 => 递归遍历

**vue3.x**  
proxy => 底层优化

## 模板编译

1. 词法分析阶段(baseParse)：template => AST(抽象语法树)
2. 指令和语法的转化阶段(transform)：AST => 解析不同的节点进行区分 => 不同类型的转换
3. 可执行函数的生成阶段(generator)：转化后 AST 生成渲染函数

- 主编译入口：core/packages/compiler-core/src/index.ts

## 基于 proxy 的响应式

1. 数据劫持 | 数据响应：检测数据变化 => 函数监听化执行
2. 依赖收集 (effect)
   - 当前 vm 实例上挂载 effect => 当前 activeEffect 切换为 effect => 在 effect 上创建 deps 等属性用于传递依赖
   - 结合 1+2 变量访问 => 触发对应的 get() => 创建 deps 对象(targetMap) => tagetMap 中的 Deps 可以作为属性进行添加(depsMap)
   - depsMap 会被添加 activeEffect - 被收集的订阅方 activeEffect 中也同时存在 deps 数组中用于存放关联方的 depsMap - 订阅者
3. 派发更新 ref
   1. 依赖的 set()被触发 => Reflect.set()修改对应属性 => 获取到 targetMap 订阅方(depsMap) => 链条传递 => 触发渲染

- 主响应式入口/core/packages/reactivity/src/index.ts

## 手写 defineReactive

```js
class Vue {
	constructor(options) {
		const data = options.data
		this._data = data

		//数据劫持
		_proxy(this, '_data', data)

		//核心逻辑
		observe(data)

		new Watch(
			this,
			function () {
				return data.name + '创建响应式'
			},
			function () {
				console.log('watch cb:', this.value)
			}
		)
	}
}

const _proxy = function (vm, sourceKey, data) {
	const keys = Object.keys(data)

	keys.forEach((key) => {
		Object.defineProperty(vm, key, {
			get() {
				return vm[sourceKey][key]
			},
			set(val) {
				vm[sourceKey][key] = val
			},
		})
	})
}

const observe = function (data) {
	const ob = new Observe(data)
}

class Observe {
	constructor(data) {
		this.walk(data)
	}
	walk(data) {
		Object.keys(data).forEach((key) => {
			let val = obj[key]
			const dep = new Dep()

			Object.defineProperty(obj, key, {
				get() {
					console.log('依赖收集')
					dep.depend()
					return val
				},
				set(newVal) {
					console.log('派发更新')
					val = newVal
					dep.notify()
				},
			})
		})
	}
}

class Dep {
	constructor() {
		this.id = Dep.uid++
		this.subs = []
	}

	addSub(sub) {
		this.subs.push(sub)
	}
	depend() {
		if (Dep.target) {
			Dep.target.addDep(this)
		}
	}
	notify() {
		this.subs.forEach((sub) => sub.update())
	}
	removeSub(sub) {
		const subIndex = this.subs.indexOf(sub)
		this.subs.splices(subIndex, 1)
	}
}

Dep.uid = 0
Dep.target = null

class Watch {
	constructor(vm, render, cb) {
		this.vm = vm
		this.render = render
		this.cb = cb

		this.deps = []
		this.depsIds = new Set()
		this.newDeps = []
		this.newDepsIds = new Set()

		this.value = this.get()
		this.cb(this.value)
	}

	get() {
		Dep.taget = this
		//重置
		this.newDeps = []
		this.newDepsIds = new Set()

		const value = this.render()

		Dep.target = null
		this.deps.forEach((oldDep) => {
			const notExistInNewDeps = !this.newDepsIds.has(oldDep.id)
			if (notExistInNewDeps) {
				oldDep.removeSub(this)
			}
		})

		this.deps = this.newDeps
		this.depsIds = this.newDepsIds

		return value
	}

	addDep(dep) {
		const depId = dep.id
		if (!this.newDepsIds.has(depId)) {
			this.newDeps.push(dep)
			this.newDepsIds.add(depId)

			if (!this.depsIds.has(depId)) {
				dep.addSub(this)
			}
		}
	}

	update() {
		this.value = this.get()
		this.cb(this.value)
	}
}
```
