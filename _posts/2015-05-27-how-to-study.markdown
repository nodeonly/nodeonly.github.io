---
layout: post
title: "如何学习nodejs？"
description: ""
keywords: ""
category: 
tags: []
---


nodejs是比较简单的，只有你有前端js基础，那就按照我的办法来吧！一周足矣

## 推荐技术栈

- express 4.x （express最新版本，初学者先别去碰koa）
- mongoose（mongodb）
- bluebird（Promise/A+实现）
- jade（视图层模板）
- mocha（测试）
- node-inspector(调试)

https://github.com/i5ting/express-starter

## 了解http协议，尤其是表单和ajax传值，在req里如何接收

- 绝对地址和相对地址
- querystring
- url 和 uri
- http status code
- http verbs
- req取参数的3种方法
- 3种不同类型的post
- 命令行玩法
- supertest用法
- what is rest?

http://i5ting.github.io/node-http/

## 了解db相关操作，先以mongoose为主

- crud（增删改查）
- 了解分页
- 了解关系（1对1，1对多）在mongoose里如何实现
- 了解statics方法和methods的区别
- 了解pre和post的差别
- 了解mongoose的插件机制
- 了解mvc里m的作用，以及什么样的代码该放到模型里
- 了解索引优化
- 了解mongodb的部署

## 了解Promise/A+规范，合理规避回调陷阱

- 了解的node的异步
- 了解异步的恶心
- 了解异步基本场景，比如waterfall这样的路程使用async如何处理
- 了解q和bluebird用法（如果有angularjs经验，推荐q，其他只推荐bluebird）
- 了解bluebird的promisifyAll用法
- 了解如何重构流程，以及代码的可读性

## 使用tdd/bdd测试，最小化问题

测试的好处，这里就不说了，但是有一点是要说的，node的调试比较难，往往不如写测试来的快，推荐学习一下

- 理解最小问题思想，培养程序员该有的强大的内心
- mocha的基本用法
- 理解assert/should/expect等断言的用法
- 理解测试生命周期
- 理解done回调
- 理解如何模拟数据
- 理解http下的supertest测试
- 理解测试覆盖率
- 理解基于gulp自动化测试方法

如果有兴趣，可以去了解更多bdd/tdd内容，甚至是cucumber.js

## 你无论如何都要会的：调试

调试有3种方法

- node debug(太挫了，如果不是c，了解adb之类的人不推荐用)
- node-inspector(推荐4※)
- tdd/bdd(推荐5※)

更多内容和视频见

https://cnodejs.org/topic/5463f6e872f405c829029f7e



欢迎关注我的公众号【node全栈】

![](/css/node全栈-公众号.png)


