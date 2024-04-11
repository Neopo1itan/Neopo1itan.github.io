---
title: OOP与继承
categories:
  - JS
tags:
  - Web
  - JavaScript
abbrlink: 3835
date: 2023-12-04 09:06:37
---

# 2023/12/4 OOP 与继承

- 器：工具，JS，VUE，React...
- 术：用前端做了什么项目。React 设计了什么，针对了什么问题，解决了什么
- 道：知识体系 -> 以道驭术

<!-- more -->

- [2023/12/4 OOP 与继承](#2023124-oop与继承)
  - [什么是面向对象 Object-oriented Programming](#什么是面向对象object-oriented-programming)
    - [JS 中的面向对象](#js中的面向对象)
      - [JS 中创建一个对象，有哪些方法？](#js中创建一个对象有哪些方法)
      - [\_\_proto\_\_本质是原型链关系](#__proto__本质是原型链关系)
      - [new 关键字](#new关键字)
      - [new 关键字到底干了什么？](#new关键字到底干了什么)
  - [继承](#继承)
    - [原型继承](#原型继承)
    - [构造函数继承](#构造函数继承)
    - [组合继承](#组合继承)
    - [组合寄生式继承](#组合寄生式继承)
  - [Q\&A](#qa)
    - [组合寄生和 class 的区别？](#组合寄生和class的区别)

## 什么是面向对象 Object-oriented Programming

**Java -> 一切皆对象**

**类**:1.属性 2.方法  
<u>对象是类的实例化</u>

```js
//面向过程
init()
whitePlay()
repaint()
check()

//面向对象
const checkerBoard = new CheckerBoard()
const whitePlayer = new Player('white')
const blackPlayer = new Player('black')

whitePlayer.start()
checkerBoard.repaint()
checkerBoard.check()

blackPlayer.start()

whitePlayer.rollback()
```

### JS 中的面向对象

#### JS 中创建一个对象，有哪些方法？

```js
var baz = Object.create({}) //baz.__proto__.__proto__ === Object.prototype
var bar = {} //bar.__proto__ === Object.prototype
var p = new Person()
```

> **Object.prototype**  
> ![OATdaG.jpg](https://ooo.0x0.ooo/2023/12/04/OATdaG.jpg)  
> _Object.prototype_ 是所有对象的原型对象，所有对象都有这个属性
> Object.prototype.constructor 指向 Object

思考：如何用 Object.create 创建一个对象实现 var bar={}一样的效果

```js
var foo = Object.create(Object.prototype)
```

#### **proto**本质是原型链关系

JS 这门语言本质设计的时候就是原型链关系
A.**proto** === B
A 上没有的方法就从 B 上找，如果 B 上有我就用 B 的

#### new 关键字

```js
function Person(name, age) {
	this.name = name
	this.age = age
}

const p = new Person('L', 35)

// 1.new创建了一个对象，这个对象的原型指向了构造函数的原型
p.__proto__ === Person.prototype
// 2.Person有个原型，原型上有个constructor是Person自己
Person.prototype.constructor === Person
// 3.p这个对象是构造函数创造的，p的构造是Person
p.constructor === Person
```

#### new 关键字到底干了什么？

- 创建了一个对象
- 这个对象的原型指向了这个 Person/Function 的 prototype
- 该对象实现了 Person 的方法
- 根据一些特定的情况返回对象
  - 如果这个函数没有返回值，或者返回一个<font color="red">非</font>对象类型,则 new 最后返回创建的这个对象（p）
  - 如果这个构造函数明确返回了一个对象(return{})，则返回这个对象

```js
// 实现new
function newFunc(Person, ...rest) {
	if (typeof Person !== 'function') {
		throw new Error('Person必须是一个函数')
	}
	var obj = Object.create(Person.prototype)
	var result = Person.apply(obj, rest)
	return result && typeof result === 'object' ? result : obj
}
// 实现Object.create
function inherit(p) {
	if (p === null) throw TypeError()
	if (Object.create) {
		return Object.create(p)
	}
	if (typeof p !== 'object' && typeof p !== 'function') throw TypeError()

	function f() {}
	f.prototype = p
	return new f()
}
```

## 继承

继承描述类和类之间的关系

### 原型继承

```js
function Parent(name) {
	this.name = ['lei', 'yu']
}

Parent.prototype.getName = function () {
	return this.name
}

function Child() {}
Child.prototype = new Parent()
Child.prototype.constructor = Child

// 1.child不传参
// 2.如果Parent有属性是引用类型，一旦修改了所有的都受影响
```

### 构造函数继承

```js
function Parent(name) {
	this.name = name
}
Parent.prototype.getName = function () {
	return this.name
}

function Child(name) {
	Parent.call(this, name)
	//调用Parent函数，并传递当前对象作为参数，以继承Parent函数的属性和方    法。
}
```

### 组合继承

```js
function Parent(name) {
	this.name = name
}
Parent.prototype.getName = function () {
	return this.name
}

function Child(name) {
	Parent.call(this, name)
	//调用Parent函数，并传递当前对象作为参数，以继承Parent函数的属性和方    法。

	// 问题：我只想构成一个原型链关系
	Child.prototype = new Parent()
	Child.prototype.constructor = Child
}
```

### 组合寄生式继承

```js
function Parent(name) {
	this.name = name
}
Parent.prototype.getName = function () {
	return this.name
}

function Child(name) {
	Parent.call(this, name)
	//调用Parent函数，并传递当前对象作为参数，以继承Parent函数的属性和方    法。

	// Child.prototype = Object.create(Parent,prototype)
	Child.prototype = inherit(Parent.prototype)
	Child.prototype.constructor = Child
}
```

![OAnbrC.jpg](https://ooo.0x0.ooo/2023/12/04/OAnbrC.jpg)

## Q&A

### 组合寄生和 class 的区别？

> Loose 模式应该差不多,主要是以下区别:
> Class 继承，会继承静态属性：
> 子类中，必须在 constructor 中调用 super，因为子类自己的 this 对象，必须先通过父类的构造函数完成
