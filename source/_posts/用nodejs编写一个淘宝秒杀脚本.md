---
title: 用nodejs编写一个淘宝秒杀脚本
categories:
  - 自动化脚本
tags:
  - nodejs
  - Web
abbrlink: 958
date: 2023-07-13 17:11:38
---
### 简介

本文运用dayjs和selenium-webdriver两个包来编写自动秒杀taobao商品的脚本，功能单一简单。
<!--more-->
脚本的流程如下：

1. 打开浏览器`chrome`，最大化并跳转到taobao.com
2. 打开登录页，人工扫码登陆
3. 登陆成功跳转到购物车界面
4. 自动点击全选按钮
5. 自动点击结算按钮

### 代码

打开命令行工具，安装该脚本所需要的两个包

```nodejs
//因为作者设置了打赏，需要在末尾加入--no-fund
npm i dayjs --save --no-fund
npm i selenium-webdriver --save --no fund
```

安装完成后，新建一个`.js`文件，名称任意，加入如下代码：

```js
const dayjs = require("dayjs");
const { By } = require("selenium-webdriver");
const selenium = require("selenium-webdriver");

const driver = new selenium.Builder().forBrowser("chrome").build();

// 最大化浏览器
driver.manage().window().maximize();
driver.get("https://www.taobao.com");
const sleep = (time) => {
  return new Promise((resolve) => {
    setTimeout(resolve, time * 1000);
  });
};
// 登录
const login = async () => {
  const loginText = driver.findElement(By.linkText("亲，请登录"));
  if (loginText) loginText.click();
  console.log("请在20秒内完成扫码");
  await sleep(20);
  driver.get("https://cart.taobao.com/cart.htm");
  await sleep(3);
  //   点击全选按钮
  if (driver.findElement(By.id("J_SelectAll1")))
    driver.findElement(By.id("J_SelectAll1")).click();
  console.log("登录成功：", dayjs(new Date()).format("YYYY-MM-DD HH:mm:ss"));
  await sleep(0.4);
  buy("20xx-xx-xx xx:xx:xx");//此处修改开售时间
};

// 秒杀
const buy = async (buyTime) => {
  while (true) {
    const now = dayjs(new Date()).format("YYYY-MM-DD HH:mm:ss");
    if (now === buyTime) {
      if (driver.findElement({ id: "J_Go" }))
        driver.findElement({ id: "J_Go" }).click();
      await sleep(0.4);
      submit();
      break;
    }
  }
};

// 提交订单
const submit = async () => {
  if (driver.findElement(By.linkText("提交订单")))
    driver.findElement(By.linkText("提交订单")).click();
  console.log("抢购时间：", dayjs(new Date()).format("YYYY-MM-DD HH:mm:ss"));
  await sleep(1000);
};

login();
```

### 运行

在该脚本文件所在位置打开命令行工具，输入：

```
//xxx.js为刚才保存的脚本文件，名字自定
node xxx.js //回车
```

脚本自动运行，扫码登陆后就在你设置好的时间开始帮你秒杀商品。

>附 python代码

```python
import datetime
import time

from selenium.webdriver.common.by import By
from selenium import webdriver
from selenium.webdriver.chrome.service import Service


# 选择chromedriver.exe路径
s = Service(r"D:\Google\Chrome\Application\chromedriver.exe")
driver = webdriver.Chrome(service=s)


def login():
driver.get("https://www.taobao.com")


if driver.find_element(By.LINK_TEXT, "亲，请登录"):
driver.find_element(By.LINK_TEXT, "亲，请登录").click()

for i in range(0, 30):
print("在" + str(30 - i) + "秒内完成扫码")
time.sleep(1)
now = datetime.datetime.now()
print('login success:', now.strftime('%Y-%m-%d %H:%M:%S.%f'))



# 购物车结算
def getcar():
driver.get("https://cart.taobao.com/cart.htm")
time.sleep(3)
# 点击购物车里全选按钮
if driver.find_element(By.ID, "J_SelectAll1"):
driver.find_element(By.ID, "J_SelectAll1").click()
time.sleep(3)



def sub_order(ordertime):
while True:
now = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S.%f')
print(now)
if now >= ordertime:
try:
# 点击结算按钮
if driver.find_element(By.ID, "J_Go"):
driver.find_element(By.ID, "J_Go").click()
now = datetime.datetime.now()
print('standby success:', now.strftime('%Y-%m-%d %H:%M:%S.%f'))
# 点击提交订单
if driver.find_element(By.CLASS_NAME, 'go-btn'):
driver.find_element(By.CLASS_NAME, "go-btn").click()
print('order success:' + str(now))
except:
pass




if __name__ == '__main__':
login()
getcar()
sub_order('2023-08-01 11:28:50.000000') #输入要抢购的时间即可
```

>参考链接:
<https://www.zhihu.com/tardis/bd/art/609639709?source_id=1001>
