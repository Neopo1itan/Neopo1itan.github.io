---
title: this指针/闭包/作用域
categories:

- 前端开发
- 培训课
tags:
- Web
- JavaScript
abbrlink: 4503
date: 2023-11-25 11:26:38

---
# 2023/11/26 this指针/闭包/作用域

**面试时必知必会**  

1. JS
2. 布局
3. 端(小程序、web)
4. 技术栈(Vue、React)  

**争取学习**  

1. 辅助技术栈
2. 热门模块和工程化  

**为我所用**  
实战 | 算法 | 模式

<!-- more -->
- [2023/11/26 this指针/闭包/作用域](#20231126-this指针闭包作用域)
  - [作用域 \& 上下文](#作用域--上下文)
    - [作用域链](#作用域链)
    - [this 上下文 context](#this-上下文-context)
      - [函数直接调用 - this指向是window](#函数直接调用---this指向是window)
      - [隐式绑定 - this指向调用堆栈的上一级](#隐式绑定---this指向调用堆栈的上一级)
      - [面试题](#面试题)
      - [显示绑定(bind | apply | call)](#显示绑定bind--apply--call)
      - [new - this指向new之后得到的实例](#new---this指向new之后得到的实例)
      - [追问：类中异步方法，this有区别吗](#追问类中异步方法this有区别吗)
    - [追问：如何突破作用域？](#追问如何突破作用域)
      - [**闭包：一个函数和它周围状态的引用捆绑在一起的组合**](#闭包一个函数和它周围状态的引用捆绑在一起的组合)
      - [函数作为参数的时候](#函数作为参数的时候)
      - [函数嵌套](#函数嵌套)
      - [事件处理（异步）的闭包](#事件处理异步的闭包)
      - [追问:立即执行函数 / 立即执行嵌套 =\> 拥有独立作用域](#追问立即执行函数--立即执行嵌套--拥有独立作用域)
      - [闭包：实现私有变量 - 高频](#闭包实现私有变量---高频)

## 作用域 & 上下文

### 作用域链

**面试题**  

```js
    let a= 'global'

    function course(){
        let b = 'bbb'

        session()
        fuction session(){
            let c = 'ccc'

            teacher()
            fuction teacher(){
                // let d = 'ddd'

                //变量提升,提升范围在当前作用域下
                //var存在声明提升和赋值提升，可以提前访问，结果为undefined
                //let仅仅存在声明提升，不会给它初始化，更不会给他赋值，暂时性死区,真正赋值才会初始化
                console.log(d)
                var d = 'yy'

                console.log(d);//作用域生效
                console.log(b);//作用域向上查找
            }
        }
    }

    course()

    // **************
    //提升优先级 => 函数需要变量
    console.log(xxx)
    var xxx =123
    function xxx(){
        console.log('functionXXX')
    }
    console.log(xxx)

    //打印结果：
    // ƒ xxx(){
    //     console.log('functionXXX')
    // }

    // 123
    //等价于
    //1.var xxx
    //2.function xxx(){}
    //3.console.log(xxx)//xxx()
    //4.xxx=123
    //5.console.log(xxx)//123
    //变量和函数同时提升时 
    //提升维度：变量优先  执行维度：函数优先

    // ********************
    // 结论：函数是天然的作用域隔离方案 => 模块化基础
```  

- 1. 对于作用域链 我们可以用创建态去定位链条中的某一环  
- 2. 手动取消链条环甚至全局作用域的时候，可以利用块级作用域做性能优化 => 性能优化

### this 上下文 context  

- this是在执行过程中动态读取的上下文所决定的

考察重点 - 各**使用态**中的指针指向

#### 函数直接调用 - this指向是window  

```js
    function foo(){
        console.log('函数内部this',this)
    }

    foo()//打印window
```

#### 隐式绑定 - this指向调用堆栈的上一级

```js
    function fn(){
        console.log('隐式绑定',this)
    }

    const obj = {
        a:1,
        fn
    }
    obj.fn = fn
    obj.fn()//打印这个obj,既 {a:1,fn:f}
```

#### 面试题

```js
const foo = {
    bar:10,
    fn:function(){
        console.log(this.bar)
        console.log(this)
    }
}
    //取出
    let fn1 = foo.fn
    fn1()//取出后打印为window，查看执行态

    //追问:
    const o1 = {
        text:'o1',
        fn:function(){
            // 直接使用上下文
            console.log('o1fn_this',this)
            return this.text
        }
    }
    
    const o2 = {
        text:'o2',
        fn:function(){
            console.log('o2fn_this',this)
            //调用者还是o1
            return o1.fn()
        }
    }

    const o3 = {
        text:'o3',
        fn:function(){
            console.log('o3fn_this',this)
            let fn = o1.fn
            // 找不到调用者，this指向windows
            return fn()
        }
    }

    console.log('o1',o1.fn())
    console.log('o2',o2.fn())
    console.log('o3',o3.fn())

```

>运行结果:
![OrDIMi.png](https://ooo.0x0.ooo/2023/11/27/OrDIMi.png)

- 1. 在执行函数的时候，函数执行时调用方上一级 => 上下文
- 2. 公共函数 | 全局调用 => window

#### 显示绑定(bind | apply | call)

- 1. call < = > apply 传参不同 依次传入 / 数组传入
- 2. bind 返回值不同

**面试**：手写apply & bind

```js
    //1.需求:手写bind => bind位置 => Function.prototype => 原型
    Function.prototype.newBind = function(){
        //1.1 bind原理 改变this

        // 暂存this，因为newBind要指向原函数
        const _this = this;
        // Array.prototype.slice.call(arguments)能够将具有length属性的arguments转换为数组,  我们可以理解为就是 arguments.toArray().slice()
        const args = Array.prototype.slice.call(arguments)
        // 获取栈顶，既是shift
        const newThis = args.shift()

        // 1.2返回值不执行 => 返回函数
        return function(){
            // 新函数传的参数，与bind传入的参数进行拼接
            const restArgs = Array.prototype.slice.call(arguments)
            const allArgs = args.concat(restArgs)
            // 执行核心，原函数执行newApply，但是上下文指向newThis
            //return _this.apply(newThis,allArgs)
            return _this.newApply(newThis,allArgs)
        }
    }

    //  2.内层实现
    Function.prototype.newApply = function(context){
        // 函数检测
        if(typeof this !== 'function'){
            throw new Error('type error');
        }
        // 参数兜底
        context = context || window

        // 临时挂载执行函数
        // 根据谁调用指向谁的原则，将this指向赋值给context（newThis）的一个属性上
        // 相当于调用了newThis.fn() 因此上下文为newThis
        context.fn = this
        let result = arguments[1]//有值的话说明有参数
            ? context.fn(...arguments[1])
            : context.fn()

        delete context.fn
        return result;
    }
```

#### new - this指向new之后得到的实例

```js
    class Course {
        constructor(name) {
            this.name = name
            console.log('构造函数中的this',this);
        }

        test(){
            console.log('类方法中的this',this)
        }
    }

    const course = new Course('this')
    course.test()
```

#### 追问：类中异步方法，this有区别吗

```js
    class Course {
        constructor(name){
            this.name = name;
            console.log('构造函数中的this:',this);
        }

        test(){
            console.log('类方法中的this:',this);
        }

        asyncTest(){
            console.log('异步方法外:',this)
            setTimeout(function(){
                console.log('异步方法内:',this)
            },500)
        }
    }
    const course = new Course('this');
    course.test();
    course.asyncTest();
```

>运行结果
>![OrGWMC.png](https://ooo.0x0.ooo/2023/11/28/OrGWMC.png)

- 1. 执行setTimeout时，匿名方法执行上下文，在队列和全局执行函数效果相同 - 指向window
- 2. 再追问，如何解决 - 记录this / 显示 / 箭头函数

### 追问：如何突破作用域？

#### **闭包：一个函数和它周围状态的引用捆绑在一起的组合**

```js
    function mail(){
        let content = '信'
        //包裹起来传递到另一个作用域，突破原作用域
        return function(){
            return content
        }
    }

    const envelop = mail()
    envelop()
```

- 函数可以作为返回值传递的

- 函数外部可以通过一定方式获取到内部的作用域变量 => 导致内部变量不被GC

#### 函数作为参数的时候

```js
    // 单一职责
    let content;
    // 通用存储
    function envelop(fn){
        content = 1;
        fn();
    }
    // 业务逻辑
    function mail(){
        console.log(content);
    }

    envelop(mail);
```

#### 函数嵌套

```js
    let counter = 0;

    function outerFn(){
        function innerFn(){
            counter++;
            console.log(counter);
        }
        return innerFn;
    }

    outerFn()();
```

#### 事件处理（异步）的闭包

```js
    let lis = document.getElementsByTagName('li');
    for(var i = 0;i<lis.length;i++){
        (function(i){
            lis[i].onclick = function(){
                console.log(i)
            }
        })(i);
    }
```

#### 追问:立即执行函数 / 立即执行嵌套 => 拥有独立作用域

```js
    (function immediateA(a){
        return (function immediateB(b){
            console.log(a);
        })(1);
    })(0);
```

- 推动了js的模块化发展

#### 闭包：实现私有变量 - 高频

```js
    const stack = {
        items:[],
        push:function(){}
    }
    
    function createStack(){
        const items = [];
        return {
            push(item){
                items.push(item)
            }
            setItems(){},
            getItems(){}
        }
    }

```
