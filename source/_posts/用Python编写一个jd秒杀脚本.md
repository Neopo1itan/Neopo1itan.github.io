---
title: 用Python编写一个jd秒杀脚本
abbrlink: 33264
date: 2023-07-17 16:33:52
categories:
  - 自动化脚本
tags:
  - python
  - Web
---
### 简介

本文运用python的selenium模块来编写实现自动秒杀jd商品的脚本。
<!--more-->
脚本的流程如下：

1. 在控制台输入抢购的时间
2. 打开浏览器，跳转到www.jd.com
3. 打开登录页，人工扫码登陆
4. 登陆成功跳转到购物车界面
5. 控制台选择全选还是手动勾选商品
6. 抢购时间自动点击结算按钮

### 准备

<font size="2" color="grey">python环境和ide工具就不作多说</font>

1. **ChromeDriver安装**：自行搜索网上教程，有很多。
2. **selenium安装**：selenium是python的第三方库，用于Web应用测试，可以直接运行在浏览器模拟用户操作。通过`pip install selenium`安装，速度慢可以替换国内镜像源，教程网上也有。

### 代码

新建一个`.py`文件打开输入如下代码

```python
from selenium import webdriver
import datetime
import time

from selenium.webdriver.common.by import By


def login():
    # 打开京东登录页，并进行扫码登录
    browser.get("https://www.jd.com")
    time.sleep(3)
    if browser.find_element(By.LINK_TEXT, "你好，请登录"):
        browser.find_element(By.LINK_TEXT, "你好，请登录").click()
        print("======请在30秒内完成登录")
        time.sleep(30)
        browser.get("https://cart.jd.com")
    time.sleep(3)
    now = datetime.datetime.now()
    print('======login success:', now.strftime('%Y-%m-%d %H:%M:%S'))
    time.sleep(5)


def buy(times, choose):
    # 点击购物车里全选按钮
    if choose == 2:
        print("======请手动勾选需要购买的商品")
    while True:
        now = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S.%f')
        # 对比时间，时间到的话就点击结算
        if now > times:
            if choose == 1:
                while True:
                    try:
                        if browser.find_element(By.ID, "J_SelectAll2"):
                            browser.find_element(By.ID, "J_SelectAll2").click()
                            break
                    except:
                        print("======找不到购买按钮")
            # 点击结算按钮
            while True:
                try:
                    if browser.find_element(By.LINK_TEXT, "去结算"):
                        browser.find_element(By.LINK_TEXT, "去结算").click()
                        print("======结算成功")
                        break
                except:
                    pass

            while True:
                try:
                    if browser.find_element(By.ID, 'order-submit'):
                        browser.find_element(By.ID, 'order-submit').click()
                        now1 = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S.%f')
                        print("======抢购成功时间：%s" % now1)
                except:
                    print("======再次尝试提交订单")
            time.sleep(0.01)
# 抢购主函数
if __name__ == "__main__":
    times = input("请输入抢购时间，格式如(2018-09-06 11:20:00.000000):")
    browser = webdriver.Chrome()
    browser.maximize_window()
    login()
    choose = int(input("到时间自动勾选购物车请输入“1”，否则输入“2”："))
    buy(times, choose)

```

值得注意的是，网上有的教程写法是`find_element_by_link_text`，运行会报错，是因为新版本selenium已经使用新的写法`find_element(By.XX, ' ')`，**XX**可以是ID，LINK_TEXT，class_name等等。

运行代码按流程操作就能秒杀抢购自己需要的商品。

>参考链接:
<https://blog.csdn.net/python03014/article/details/130477281>
