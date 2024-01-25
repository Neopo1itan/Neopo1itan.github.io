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

### /bin/vue-init

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
