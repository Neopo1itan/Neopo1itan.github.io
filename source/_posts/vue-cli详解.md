---
title: vue-cli 详解
abbrlink: 38044
date: 2024-01-25 16:40:22
tags:
  - Web
  - Vue
categories:
  - 前端开发
  - 培训课
---

> **vue-cli**
>
> - 基础:用于生成项目文件体系的搭建 + 用户交互
> - metadata 配置(元数据)
> - parser & render

## vue-cli_2.x.x

### /bin/vue-init 前置工作

```js
// 下载远程仓库 => 远程拉去github内的配置
const download = require('download-git-repo')
// 命令行处理工具
const program = require('commander')
// node下的文件操作系统中的existsSync - 监测是否存在该路径
const exists = require('fs').existsSync
// node自带的拼接路径的模块
const path = require('path')
// 命令行中的加载效果
const ora = require('ora')
// 获取用户根目录
const home = require('user-home')
// 绝对路径替换为波浪号
const tildify = require('tildify')
// 高亮
const chalk = require('chalk')
// **important** 用户与脚本命令行的交互 | 面试
const inquirer = require('inquirer')
// rm -rf js版本
const rm = require('rimraf').sync
```

#### 面试题：如何使用本地模板，预设模板 而不是 github？

使用 **--offline**

#### 如何获取用户参数

> vue init webpack zhaowa-app

program.args[0] => 'webpack'  
// 是否包含斜杠 => 路径层级 =>非默认预制模板  
const hasSlash = template.indexOf('/')>-1

// 项目名称  
rawName = program.args[1]

//输入是否为空 => 是否以当前文件目录作为项目根目录  
const inPlace = !rawName || '.'

//调整当前目录作为构建目录的根路径  
const name = inPlace ....

//本地目录模板仓库路径拼接 /zhaowa/.vue-templates/webpack  
const tmp = path.join(home,'...')

### /lib/generate.js

```js
// 静态网页文件生成器
const Metalsmith
// 模板引擎
const Handlebars
// 多条件匹配工具
const multimatch
```

### /lib/ask.js

解析传进来的模板有哪些要询问的

inquirer.prompt

### /lib/filter.js 过滤不需要的

## vue-cli_3.x.x

### /lib/create.js

```js
const creator = new Creator(name, targetDir, getPromptModules())
await creator.create(options)
```

### /lib/Creator.js

```js
module.exports = class Creator extends EventEmitter {}
```

## 流程

用户创建指令 -> 创建参数解析 -> 加载模板(远端/本地) -- prompts --> 处理文件路径 -> 文件层级处理 -> 文件模板渲染(plugins) -> 产出包

如何书写 node 脚本工具
