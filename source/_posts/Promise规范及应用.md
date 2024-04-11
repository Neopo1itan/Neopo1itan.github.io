---
title: Promise规范及应用
tags:
  - JS
categories:
  - 前端开发
  - 培训课
abbrlink: 7303
date: 2023-12-08 08:58:28
---

# 2023/12/11 Promise 规范及应用

- [2023/12/11 Promise 规范及应用](#20231211-promise-规范及应用)
  - [1 异步的逻辑](#1-异步的逻辑)
  - [2 异步的发展](#2-异步的发展)
    - [Callback](#callback)
    - [Promise](#promise)
    - [Generator](#generator)
    - [async / await](#async--await)
  - [3 Promise 深入理解](#3-promise-深入理解)
    - [3.1 初探 Promise](#31-初探-promise)
      - [规则](#规则)
      - [测试](#测试)
      - [问题](#问题)
    - [3.2 Promise 进阶](#32-promise-进阶)
      - [规则](#规则-1)
      - [实现](#实现)
      - [问题](#问题-1)
    - [3.3 Promise 的链式调用](#33-promise-的链式调用)
      - [规则](#规则-2)
      - [实现](#实现-1)
      - [选读：resolvePromise 规范](#选读resolvepromise-规范)
      - [实现](#实现-2)
    - [3.4 Promise 的一些理解](#34-promise-的一些理解)
      - [链式执行](#链式执行)
      - [手动触发](#手动触发)

<!-- more -->

## 1 异步的逻辑

![OARqNM.jpg](https://ooo.0x0.ooo/2023/12/07/OARqNM.jpg)

> **宏任务**：script（整体代码）、setTimeout、setInterval、setImmediate、I/O、UI rendering  
> **微任务**：promise、Object.observe、MutationObserver  
> promise.nextTick > promise.then > setTimeout > setImmediate

```js
setTimeout(function () {
	console.log(1)
}, 0)

new Promise(function (resolve) {
	console.log(2)
	resolve()
	console.log(3)
}).then(function () {
	console.log(4)
})

console.log(5)

//2
//3
//5
//4
//1
```

## 2 异步的发展

```js
// 一般情况
function foo()
{
  const bar = 'bar'
  return bar;
}

// 如果调用后1000s再拿到bar该如何调用
function foo(cb:Function){
  const bar = 'bar'
  setTimeout(()=>{
    cb(bar)
  },1000)
}

foo(res)=>{
  // res就是想要的bar
  //但是想基于bar的值以后再写新的逻辑只能在这里写
}
```

### Callback

当没有 Promise 的时候，大量的异步逻辑回调，都依赖于 callback

> 在 node 中大量的:
>
> ```js
> fs.readFile('a.text', 'utf-8', function (err, data) {
> 	fs.readFile('a.text', 'utf-8', function (err, data) {
> 		fs.readFile('a.text', 'utf-8', function (err, data) {})
> 	})
> })
> ```

### Promise

应用 -> fetch,webpack

```js
export const getData = () => post('xxx/xxxx')

getData().then((res) => {
	this.dataList = res.data
})

function post(url) {
	return new Promise((resolve, reject) => {
		setTimeout(() => {
			resolve({ data: [], url })
		}, 1000)
	})
}
```

### Generator

```js
function* gen() {
	yield 1
	yield 1
	let res = yield 3
	return res
}

let result = gen()
console.log(result.next())
console.log(result.next())
console.log(result.next())
console.log(result.next('over'))
```

### async / await

异步编程的改进,提供一种不阻塞主线程的情况下,使用同步代码执行异步的逻辑

```js
async function post(url) {
	return new Promise((resolve, reject) => {
		setTimeout(() => {
			resolve({ data: [], url })
		}, 1000)
	})
}

const getData = async () => await post('xxx/xxx')

const run = async () => {
	console.log('starting')
	const result = await getData()
	console.log(result)
}
run()
```

## 3 Promise 深入理解

### 3.1 初探 Promise

#### 规则

> - `Promise`是一个构造函数
> - `Promise`接受一个函数作为参数,这个函数的参数式两个函数(`resolve`和`reject`)
> - `Promise`返回一个对象,这个对象包含一个 then 函数,这个`then`函数接受两个函数参数
> - `Promise`的**status**:
> - - `pending`
> - - - 初始状态,可以改变
> - - - 一个`Promise`在`resolve`和`reject`之前都是这个状态
> - - - 可以通过调用`resolve`或者`reject`方法,让这个`Promise`变成`fullfilled`或者`rejected`状态
> - - `fulfilled`
> - - - 不可变状态
> - - - 在`resolve`之后变成这个状态,拥有一个`value`
> - - `rejected`
> - - - 不可变状态
> - - - 在`rejected`之后变成这个状态,拥有一个 reason
> - `then`函数
> - - **参数**
> - - - `onFulfilled`,`onRejected`必须是函数类型,如果不是,应该被忽略:
> - - `onFulfilled`和`onRejected`的特性
> - - - 在 promise 变成`fulfilled` / `rejected`状态的时候,应该调用`onFulfilled`或者`onRejected`
> - - - 在 promise 变成`fulfilled` / `rejected`状态之前,不应该调用
> - - - 只能调用一次

```js
function Lpromise(execute) {
	this.status = 'pending'
	this.value = null
	this.reason = null
	this.onFulfilled = null
	this.onRejected = null

	const resolve = (value) => {
		// pending才是可变状态
		if (this.status === 'pending') {
			this.status = 'fulfilled'
			this.value = value
		}
	}

	const reject = (reason) => {
		// pending才是可变状态
		if (this.status === 'pending') {
			this.status = 'rejected'
			this.reason = reason
		}
	}

	execute(resolve, reject)
}

Lpromise.prototype.then = function (onFulfilled, onRejected) {
	onFulfilled =
		typeof onFulfilled === 'function'
			? onFulfilled
			: (data) => {
					return data
			  }
	onRejected =
		typeof onRejected === 'function'
			? onRejected
			: (error) => {
					throw error
			  }
	if (this.status === 'fulfilled') {
		onFulfilled(this.value)
	}
	if (this.status === 'rejected') {
		onRejected(this.reason)
	}
}
```

#### 测试

```js
new Lpromise((resolve, reject) => {
	resolve('hello')
}).then((res) => {
	console.log(res)
})
```

#### 问题

```js
new Lpromise((resolve, reject) => {
	setTimeout(() => {
		resolve('hello')
	}, 1000)
}).then((res) => {
	console.log(res)
})
```

没有输出了  
因在执行`resolve`的时候,`then`已经执行过了  
所以要在一个合适的时机,去执行`then`的`onFulfilled`

### 3.2 Promise 进阶

#### 规则

> - `resolve`/`reject`执行了之后，再执行`onfulfilled`和`onrejected`
> - `onfulfilled`和`onrejected`应该是微任务

#### 实现

```js
function Lpromise(execute) {
	this.status = 'pending'
	this.value = null
	this.reason = null
	this.onFulfilledArray = []
	this.onRejectedArray = []

	const resolve = (value) => {
		//queueMicrotask 方法用于将一个微任务添加到微任务队列中。微任务是异步执行的任务，它们在宏任务之间插入。
		queueMicrotask(() => {
			if (this.status === 'pending') {
				this.status = 'fulfilled'
				this.value = value
				this.onFulfilledArray.forEach((fn) => fn(value))
			}
		})
	}

	const reject = (reason) => {
		queueMicrotask(() => {
			if (this.status === 'pending') {
				this.status = 'rejected'
				this.reason = reason
				this.onRejectedArray.forEach((fn) => fn(reason))
			}
		})
	}

	execute(resolve, reject)
}

Lpromise.prototype.then = function (onFulfilled, onRejected) {
	onFulfilled =
		typeof onFulfilled === 'function'
			? onFulfilled
			: (data) => {
					return data
			  }
	onRejected =
		typeof onRejected === 'function'
			? onRejected
			: (error) => {
					throw error
			  }
	if (this.status === 'fulfilled') {
		onFulfilled(this.value)
	}
	if (this.status === 'rejected') {
		onRejected(this.reason)
	}
	if (this.status === 'pending') {
		this.onFulfilledArray.push(onFulfilled)
		this.onRejectedArray.push(onRejected)
	}
}
```

![OAVYUi.png](https://ooo.0x0.ooo/2023/12/11/OAVYUi.png)

#### 问题

链式调用无法 work

### 3.3 Promise 的链式调用

#### 规则

> **then**方法应该返回一个 promise  
> `promise2 = promise1.then(onFulfilled,onRejected)`
>
> - `onFulfilled`/`onRejected`的执行结果为 x 调用`resolvePromise`
> - 如果`onFulfilled`/`onRejected`执行时抛出异常，我们 promise2 需要被 reject
> - 如果`onFulfilled`/`onRejected`不是一个函数，promise2 以 promise1 的 valve 或者 reason 触发 fulfilled 和 rejected  
>   **promise1 中的 onfulfilled 返回了一个值，这个值需要被 promise2 进行 resolve，才能出现在下一个 then(res)。**

#### 实现

```js
function Lpromise(execute) {
	this.status = 'pending'
	this.value = null
	this.reason = null
	this.onFulfilledArray = []
	this.onRejectedArray = []

	const resolve = (value) => {
		//queueMicrotask 方法用于将一个微任务添加到微任务队列中。微任务是异步执行的任务，它们在宏任务之间插入。
		queueMicrotask(() => {
			if (this.status === 'pending') {
				this.status = 'fulfilled'
				this.value = value
				this.onFulfilledArray.forEach((fn) => fn(value))
			}
		})
	}

	const reject = (reason) => {
		queueMicrotask(() => {
			if (this.status === 'pending') {
				this.status = 'rejected'
				this.reason = reason
				this.onRejectedArray.forEach((fn) => fn(reason))
			}
		})
	}
	// try catch
	execute(resolve, reject)
}

Lpromise.prototype.then = function (onFulfilled, onRejected) {
	onFulfilled =
		typeof onFulfilled === 'function'
			? onFulfilled
			: (data) => {
					return data
			  }
	onRejected =
		typeof onRejected === 'function'
			? onRejected
			: (error) => {
					throw error
			  }

	// 实现链式then
	let promise2

	if (this.status === 'fulfilled') {
		// old:onFulfilled(this.value);
		// 返回新的Promise
		return (promise2 = new LPromise((resolve, reject) => {
			queueMicroMask(() => {
				try {
					// promise1中的onfulfilled返回了一个值，是then返回的promise2中需要resolve的
					let result = onFulfilled(this.value)
					resolve(result)
				} catch (e) {
					reject(e)
				}
			})
		}))
	}
	if (this.status === 'rejected') {
		// old:onRejected(this.reason);
		// 返回新的Promise
		return (promise2 = new LPromise((resolve, reject) => {
			queueMicroMask(() => {
				try {
					let result = onRejected(this.reason)
					resolve(result)
				} catch (e) {
					reject(e)
				}
			})
		}))
	}
	if (this.status === 'pending') {
		// old
		// this.onFulfilledArray.push(onFulfilled);
		// this.onRejectedArray.push(onRejected);
		return (promise2 = new LPromise((resolve, reject) => {
			this.onFulfilledArray.push(() => {
				try {
					let result = onFulfilled(this.value)
					resolve(result)
				} catch (e) {
					reject(e)
				}
			})

			this.onRejectedArray.push(() => {
				try {
					let result = onRejected(this.reason)
					resolve(result)
				} catch (e) {
					reject(e)
				}
			})
		}))
	}
}
```

#### 选读：resolvePromise 规范

`resolvePromise(promise2,x,resolve,reject)`

- 如果 promise2 和 x 相等，那么 reject error;
- 如果 promise2 是一个 promise
  - 如果 x 是一个 pending 状态，那么 promise2 必须要再 pending, 直到 x 变成 fulfilled / rejected
  - 如果 x 被 fulfilled， fulfill promise with the same value
  - 如果 x 被 rejected， reject promise with the same reason
- 如果 x 是一个 object 或者 function
  - Let thenable = x.then
  - 如果 x.then 这一步出错，那么 reject promise with e as the reason
  - 如果 then 是一个函数，then.call(x, resolvePromiseFn, rejectPromiseFn)
    - resolvePromiseFn 的入参是 y, 执行 resolvePromise(promise2, y, resolve, reject)
    - rejectPromiseFn 的入参是 r, reject promise with r
    - 如果 resolvePromiseFn 和 rejectPromiseFn 都调用了，那么第一个调用优先，后面的忽略
    - 如果调用 then 抛出异常
      - 如果 resolvePromise 或 rejectPromise 已经被调用，可以忽略
    - 如果 then 不是一个 function， fulfill promise with x

#### 实现

```js
const resolvePromise = (promise2, result, resolve, reject) => {
	// 当 result 和 promise2 相等时，也就是说 onfulfilled 返回 promise2 时，进行 reject
	if (result === promise2) {
		reject(new TypeError('error due to circular reference'))
	}

	// 是否已经执行过 onfulfilled 或者 onrejected
	let consumed = false
	let thenable

	if (result instanceof LPromise) {
		if (result.status === 'pending') {
			result.then(function (data) {
				resolvePromise(promise2, data, resolve, reject)
			}, reject)
		} else {
			result.then(resolve, reject)
		}
		return
	}

	let isComplexResult = (target) => (typeof target === 'function' || typeof target === 'object') && target !== null

	// 如果返回的是疑似 Promise 类型
	if (isComplexResult(result)) {
		try {
			thenable = result.then
			// 如果返回的是 Promise 类型，具有 then 方法
			if (typeof thenable === 'function') {
				thenable.call(
					result,
					function (data) {
						if (consumed) {
							return
						}
						consumed = true

						return resolvePromise(promise2, data, resolve, reject)
					},
					function (error) {
						if (consumed) {
							return
						}
						consumed = true

						return reject(error)
					}
				)
			} else {
				resolve(result)
			}
		} catch (e) {
			if (consumed) {
				return
			}
			consumed = true
			return reject(e)
		}
	} else {
		resolve(result)
	}
}

function LPromise(execute) {
	this.status = 'pending'
	this.value = null
	this.reason = null

	this.onFulfilledArray = []
	this.onRejectedArray = []

	const resolve = (value) => {
		queueMicrotask(() => {
			if (this.status === 'pending') {
				this.value = value
				this.status = 'fulfilled'
				this.onFulfilledArray.forEach((func) => func(value))
			}
		})
	}

	const reject = (reason) => {
		queueMicrotask(() => {
			if (this.status === 'pending') {
				this.reason = reason
				this.status = 'rejected'
				this.onRejectedArray.forEach((func) => func(reason))
			}
		})
	}
	// try catch
	execute(resolve, reject)
}

LPromise.prototype.then = function (onFulfilled, onRejected) {
	onFulfilled =
		typeof onFulfilled === 'function'
			? onFulfilled
			: (data) => {
					return data
			  }
	onRejected =
		typeof onRejected === 'function'
			? onRejected
			: (error) => {
					throw error
			  }

	let promise2

	if (this.status === 'fulfilled') {
		return (promise2 = new LPromise((resolve, reject) => {
			queueMicrotask(() => {
				try {
					// promise1 中 onfulfilled 返回了一个值，这个值需要被 promise2 进行 resolve ，才能出现在下一个 then(res)
					let x = onFulfilled(this.value)
					resolvePromise(promise2, x, resolve, reject)
				} catch (e) {
					reject(e)
				}
			})
		}))
	}

	if (this.status === 'rejected') {
		return (promise2 = new LPromise((resolve, reject) => {
			queueMicrotask(() => {
				try {
					// promise1 中 onfulfilled 返回了一个值，这个值需要被 promise2 进行 resolve ，才能出现在下一个 then(res)
					let x = onRejected(this.reason)
					resolvePromise(promise2, x, resolve, reject)
				} catch (e) {
					reject(e)
				}
			})
		}))
	}

	if (this.status === 'pending') {
		return (promise2 = new LPromise((resolve, reject) => {
			this.onFulfilledArray.push(() => {
				try {
					let x = onFulfilled(this.value)
					resolvePromise(promise2, x, resolve, reject)
				} catch (e) {
					reject(e)
				}
			})
			this.onRejectedArray.push(() => {
				try {
					// promise1 中 onfulfilled 返回了一个值，这个值需要被 promise2 进行 resolve ，才能出现在下一个 then(res)
					let x = onRejected(this.reason)
					resolvePromise(promise2, x, resolve, reject)
				} catch (e) {
					reject(e)
				}
			})
		}))
	}
}
```

### 3.4 Promise 的一些理解

#### 链式执行

> 100 个 promise，10 个先执行，每 resolve 一个，加一个进去。形成 stream.

```js
const promiseArrGenerator = (num) =>
	new Array(num).fill(0).map(
		(item, index) => () =>
			new Promise((resolve, reject) => {
				setTimeout(() => {
					resolve(index)
				}, Math.random() * 1000)
			})
	)

let arr = promiseArrGenerator(100)

// arr.map((fn) => {
//     fn().then(console.log)
// })
// Promise.all(arr.map(fn => fn())).then(res => console.log(res))

// 设计一个 promise Chain 链式调用

const promiseChain = (arr) => {
	arr.reduce(
		(proChain, pro) =>
			proChain.then((res) => {
				~res && console.log(res)
				return pro()
			}),
		Promise.resolve(-1)
	)
}

promiseChain(arr)
```

#### 手动触发

> sleep 函数，halk 函数

```js
const engine = (cb) => {
	let _resolve

	new Promise((resolve, reject) => {
		_resolve = resolve
	}).then((res) => {
		cb()
	})

	return {
		start: () => {
			_resolve()
		},
	}
}

let e = engine(() => {
	console.log('engine')
})

e.start()
```
