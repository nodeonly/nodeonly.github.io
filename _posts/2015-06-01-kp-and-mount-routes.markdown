---
layout: post
title: "分享2个实用的nodejs模块"
description: ""
keywords: ""
category: 
tags: []
---

分享2个实用的nodejs模块

- kp 根据端口号杀死进程，尤其对于pm2的集群模式，僵尸进程有效
- mount-routes 根据路径来自动加载路由，让开发更简单

## kp

kp is a tool for kill process by server port. only use for mac && linux

[![npm version](https://badge.fury.io/js/kp.svg)](http://badge.fury.io/js/kp)

### Install

    [sudo]npm install -g kp

### Usage 

default server port is 3000

```
kp
```

根据某个端口

```
kp 3002
```

支持sudo，因为有的时候有权限的问题

```
kp 3002 -s or kp 3002 --sudo
```

目前centos/ubuntu和mac已经测过

感谢@jysperm反馈：fuser 来自 psmisc 这个包（killall 也在这个包里），Ubuntu 默认安装，其他系统不清楚。

没有使用fuser的原因是：fuser，但在mac上不能用

## mount-routes

mount-routes = auto mount express routes with routes_folder_path

### Install

    npm install --save mount-routes

### Usages


```
var express = require('express')
var app = express()

var mount = require('mount-routes');

// simple
// mount(app);

// with path
mount(app,'routes2');

// start server
app.listen(23018)
```

### 使用方式1  mount(app);

可以自动挂载routes目录的所有路由，以文件名称作为路由的根

比如 `routes/movies.js`

它相当于

```
var movies = require('./config/routes/movies');
app.use('/movies',movies);
```

### 使用方式2  mount(app,'routes2');

可以根据第二个参数，即路由目录文件夹的名称，自动挂载它下面的所有路由，以文件名称作为路由的根

比如 `routes2/movies.js`

它相当于

```
var movies = require('./config/routes2/movies');
app.use('/movies',movies);
```

### 总结

可以一次挂载多个路由目录

```
// simple
mount(app);

// with path
mount(app,'routes2');
```

但要小心文件名不能重复，不然会有问题，比如

- routes/movies.js
- routes2/movies.js

它们会挂载到同一个path上，这种情况下需要谨慎使用，以后版本会考虑改进


## 源码

欢迎反馈和贡献

- https://github.com/i5ting/kp
- https://github.com/i5ting/mount-routes



欢迎关注我的公众号【node全栈】

![](/css/node全栈-公众号.png)


