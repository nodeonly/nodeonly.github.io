---
layout: post
title: "Koa 还是 Express？"
description: ""
keywords: ""
category: 
tags: []
---

群里很多人在问到底该用Koa还是express，本文会对比2个框架的各种细节，并给出指导意见，希望能够为大家解惑。

- http://koajs.com/
- http://expressjs.com/

## koa

koa 是由 Express 原班人马打造的，致力于成为一个更小、更富有表现力、更健壮的 Web 框架。使用 koa 编写 web 应用，通过组合不同的 generator，可以免除重复繁琐的回调函数嵌套，并极大地提升错误处理的效率。koa 不在内核方法中绑定任何中间件，它仅仅提供了一个轻量优雅的函数库，使得编写 Web 应用变得得心应手。

### 版本要求

Koa 目前需要 >=0.11.x版本的 node 环境。并需要在执行 node 的时候附带 --harmony 来引入 generators 。 

express无所谓，目前0.10+都ok，甚至更低版本

### 中间件变化

Koa 应用是一个包含一系列中间件 generator 函数的对象。 这些中间件函数基于 request 请求以一个类似于栈的结构组成并依次执行。 Koa 类似于其他中间件系统（比如 Ruby's Rack 、Connect 等）， 然而 Koa 的核心设计思路是为中间件层提供高级语法糖封装，以增强其互用性和健壮性，并使得编写中间件变得相当有趣。

Koa 包含了像 content-negotiation（内容协商）、cache freshness（缓存刷新）、proxy support（代理支持）和 redirection（重定向）等常用任务方法。 与提供庞大的函数支持不同，Koa只包含很小的一部分，因为Koa并不绑定任何中间件。

和 express 基于的中间件Connect，差别并不大，思想都是一样的，它里面说的

    增强其互用性和健壮性
    
我还没玩出太多感想，请大家指点

除了`yield next;`外，并无其他

yield要说一下，必须在处理的中间件里才会回调

比如


    var koa = require('koa');
    var app = koa();

    //1 x-response-time

    app.use(function *(next){
      var start = new Date;
      yield next;
      var ms = new Date - start;
      this.set('X-Response-Time', ms + 'ms');
    });

    //2 logger

    app.use(function *(next){
      var start = new Date;
      yield next;
      var ms = new Date - start;
      console.log('%s %s - %s', this.method, this.url, ms);
    });

    //3 response

    app.use(function *(){
      this.body = 'Hello World';
    });

    app.listen(3000);


在程序启动的时候，1和2是没有执行的，只有当执行到任意请求，比如3的时候，它才会调用1和2

## 错误处理

koa


    app.on('error', function(err){
      log.error('server error', err);
    });


而在新版的express里


    server.on('error', onError);


    /**
     * Event listener for HTTP server "error" event.
     */

    function onError(error) {
      if (error.syscall !== 'listen') {
        throw error;
      }

      var bind = typeof port === 'string'
        ? 'Pipe ' + port
        : 'Port ' + port;

      // handle specific listen errors with friendly messages
      switch (error.code) {
        case 'EACCES':
          console.error(bind + ' requires elevated privileges');
          process.exit(1);
          break;
        case 'EADDRINUSE':
          console.error(bind + ' is already in use');
          process.exit(1);
          break;
        default:
          throw error;
      }
    }

二者实际上没有啥大差别

### Koa Context 

将 node 的 request 和 response 对象封装在一个单独的对象里面，其为编写 web 应用和 API 提供了很多有用的方法。

这些操作在 HTTP 服务器开发中经常使用，因此其被添加在上下文这一层，而不是更高层框架中，因此将迫使中间件需要重新实现这些常用方法。

context 在每个 request 请求中被创建，在中间件中作为接收器(receiver)来引用，或者通过 this 标识符来引用：

    app.use(function *(){
      this; // is the Context
      this.request; // is a koa Request
      this.response; // is a koa Response
    });

比express里爽一些，express里中间件可变参数还是会比较恶心，而且性能也不好


### 对比一些api

- req
- res

基本上一模一样

### 二者比较总结

https://github.com/koajs/koa/blob/master/docs/koa-vs-express.md



| Feature           | Koa | Express | Connect |
|------------------:|-----|---------|---------|
| Middleware Kernel | ✓   | ✓       | ✓       |
| Routing           |     | ✓       |         |
| Templating        |     | ✓       |         |
| Sending Files     |     | ✓       |         |
| JSONP             |     | ✓       |         |


Does Koa replace Express?

It's more like Connect, but a lot of the Express goodies were moved to the middleware level in Koa to help form a stronger foundation. This makes middleware more enjoyable and less error-prone to write, for the entire stack, not just the end application code.

Typically many middleware would re-implement similar features, or even worse incorrectly implement them, when features like signed cookie secrets among others are typically application-specific, not middleware specific.


拿koa来比较express并不太合适，可以说它是介于connect和express中间的框架

- 与connect类似都是调用栈思想，但修改了中间件模式，使用generator
- 把express里的一些好的东西加进去，但剔除了路由，视图渲染等特性


## 总结

koa是一个比express更精简，使用node新特性的中间件框架，相比之前express就是一个庞大的框架

- 如果你喜欢diy，很潮，可以考虑koa，它有足够的扩展和中间件，而且自己写很简单
- 如果你想简单点，找一个框架啥都有，那么先express

koa是大势所趋，我很想用，但我目前没有选koa，我的考虑

- 0.11下我目前没有搞定node-inspector，所以我啥时候搞定，啥时候迁移
- 团队成本问题，如果他们连express都不会，上来就koa，学习曲线太逗，不合适
- 目前基于express的快读开发框架需要一段时间迁移到koa

和es6的考虑是一样的，又爱又恨，先做技术储备，只要时机ok，毫不犹豫的搞起。


目前express由strongloop负责，它的下一步如何发展，还说不好，比如5.0、6.0是否会用koa作为中间件也不好说

koa代码很少，可以很容易读完

https://github.com/koajs/koa


另外值得提得一点是，核心开发者 @dead-horse 是阿里的员工，赞一下国内的开源。



全文完

欢迎关注我的公众号【node全栈】

![](/css/node全栈-公众号.png)
