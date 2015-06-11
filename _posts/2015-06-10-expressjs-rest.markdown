---
layout: post
title: "监控Nodejs的页面响应时间"
description: ""
keywords: ""
category: 
tags: []
---


## 监控Nodejs的页面响应时间

最近想监控一下Nodejs的性能。记录分析Log太麻烦，最简单的方式是记录每个HTTP请求的处理时间，直接在HTTP Response Header中返回。

记录HTTP请求的时间很简单，就是收到请求记一个时间戳，响应请求的时候再记一个时间戳，两个时间戳之差就是处理时间。

但是，res.send()代码遍布各个js文件，总不能把每个URL处理函数都改一遍吧。

正确的思路是用middleware实现。但是Nodejs没有任何拦截res.send()的方法，怎么破？

其实只要稍微转换一下思路，放弃传统的OOP方式，以函数对象看待res.send()，我们就可以先保存原始的处理函数res.send，再用自己的处理函数替换res.send：

app.use(function (req, res, next) {
    // 记录start time:
    var exec_start_at = Date.now();
    // 保存原始处理函数:
    var _send = res.send;
    // 绑定我们自己的处理函数:
    res.send = function () {
        // 发送Header:
        res.set('X-Execution-Time', String(Date.now() - exec_start_at));
        // 调用原始处理函数:
        return _send.apply(res, arguments);
    };
    next();
});
只用了几行代码，就把时间戳搞定了。

对于res.render()方法不需要处理，因为res.render()内部调用了res.send()。

调用apply()函数时，传入res对象很重要，否则原始的处理函数的this指向undefined直接导致出错。

实测首页响应时间9毫秒：


![](/css/2015-06-10/1.png)

原作者廖雪峰  
原文链接 http://www.liaoxuefeng.com/article/0014007460517001bbb3e2f624a4917b742635e9a6b15dd000

### 点评

- 以中间价来处理是复用最大的方法，全局中间价是每一个http请求都要经过的
- 通过apply给res对象增加header，只要出发res.send就会带上header是很巧妙的做法
- res.send是所有res的最底层方法，其他方法也会调用，比如res.json也会调用send

## send源码

这是express里res.send方法的源码

    /**
     * Send a response.
     *
     * Examples:
     *
     *     res.send(new Buffer('wahoo'));
     *     res.send({ some: 'json' });
     *     res.send('<p>some html</p>');
     *
     * @param {string|number|boolean|object|Buffer} body
     * @api public
     */

    res.send = function send(body) {
      var chunk = body;
      var encoding;
      var len;
      var req = this.req;
      var type;

      // settings
      var app = this.app;

      // allow status / body
      if (arguments.length === 2) {
        // res.send(body, status) backwards compat
        if (typeof arguments[0] !== 'number' && typeof arguments[1] === 'number') {
          deprecate('res.send(body, status): Use res.status(status).send(body) instead');
          this.statusCode = arguments[1];
        } else {
          deprecate('res.send(status, body): Use res.status(status).send(body) instead');
          this.statusCode = arguments[0];
          chunk = arguments[1];
        }
      }

      // disambiguate res.send(status) and res.send(status, num)
      if (typeof chunk === 'number' && arguments.length === 1) {
        // res.send(status) will set status message as text string
        if (!this.get('Content-Type')) {
          this.type('txt');
        }

        deprecate('res.send(status): Use res.sendStatus(status) instead');
        this.statusCode = chunk;
        chunk = http.STATUS_CODES[chunk];
      }

      switch (typeof chunk) {
        // string defaulting to html
        case 'string':
          if (!this.get('Content-Type')) {
            this.type('html');
          }
          break;
        case 'boolean':
        case 'number':
        case 'object':
          if (chunk === null) {
            chunk = '';
          } else if (Buffer.isBuffer(chunk)) {
            if (!this.get('Content-Type')) {
              this.type('bin');
            }
          } else {
            return this.json(chunk);
          }
          break;
      }

      // write strings in utf-8
      if (typeof chunk === 'string') {
        encoding = 'utf8';
        type = this.get('Content-Type');

        // reflect this in content-type
        if (typeof type === 'string') {
          this.set('Content-Type', setCharset(type, 'utf-8'));
        }
      }

      // populate Content-Length
      if (chunk !== undefined) {
        if (!Buffer.isBuffer(chunk)) {
          // convert chunk to Buffer; saves later double conversions
          chunk = new Buffer(chunk, encoding);
          encoding = undefined;
        }

        len = chunk.length;
        this.set('Content-Length', len);
      }

      // populate ETag
      var etag;
      var generateETag = len !== undefined && app.get('etag fn');
      if (typeof generateETag === 'function' && !this.get('ETag')) {
        if ((etag = generateETag(chunk, encoding))) {
          this.set('ETag', etag);
        }
      }

      // freshness
      if (req.fresh) this.statusCode = 304;

      // strip irrelevant headers
      if (204 == this.statusCode || 304 == this.statusCode) {
        this.removeHeader('Content-Type');
        this.removeHeader('Content-Length');
        this.removeHeader('Transfer-Encoding');
        chunk = '';
      }

      if (req.method === 'HEAD') {
        // skip body for HEAD
        this.end();
      } else {
        // respond
        this.end(chunk, encoding);
      }

      return this;
    };


没啥难点


    res.json = function json(obj) {
      var val = obj;

      // allow status / body
      if (arguments.length === 2) {
        // res.json(body, status) backwards compat
        if (typeof arguments[1] === 'number') {
          deprecate('res.json(obj, status): Use res.status(status).json(obj) instead');
          this.statusCode = arguments[1];
        } else {
          deprecate('res.json(status, obj): Use res.status(status).json(obj) instead');
          this.statusCode = arguments[0];
          val = arguments[1];
        }
      }

      // settings
      var app = this.app;
      var replacer = app.get('json replacer');
      var spaces = app.get('json spaces');
      var body = JSON.stringify(val, replacer, spaces);

      // content-type
      if (!this.get('Content-Type')) {
        this.set('Content-Type', 'application/json');
      }

      return this.send(body);
    };

这里的的最后一行`return this.send(body)`,它实际上就上面的res.send方法

其他方法也一样

- jsonp
- render

## 自己要用，于是copy了一份

request-time

Install

    npm install --save request-time
    
Usages

    var express       = require('express');
    var request-time  = require('request-time');

    var app = new express();
    app.use(request-time);



欢迎关注我的公众号【node全栈】

![](/css/node全栈-公众号.png)
