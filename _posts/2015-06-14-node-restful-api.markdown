---
layout: post
title: "Nodejs RESTFul架构实践之api"
description: ""
keywords: ""
category: 
tags: []
---

## why token based auth?

此段摘自 http://zhuanlan.zhihu.com/FrontendMagazine/19920223
英文原文 http://code.tutsplus.com/tutorials/token-based-authentication-with-angularjs-nodejs--cms-22543


在讨论了关于基于 token 认证的一些基础知识后，我们接下来看一个实例。看一下下面的几点，然后我们会仔细的分析它：

![](/css/2015-06-14/1.jpg)

1. 多个终端，比如一个 web 应用，一个移动端等向 API 发送特定的请求。
1. 类似 [https://api.yourexampleapp.com](https://api.yourexampleapp.com) 这样的请求发送到服务层。如果很多人使用了这个应用，需要多个服务器来响应这些请求操作。
1. 这时，负载均衡被用于平衡请求，目的是达到最优化的后端应用服务。当你向 [https://api.yourexampleapp.com](https://api.yourexampleapp.com) 发送请求，最外层的负载均衡会处理这个请求，然后重定向到指定的服务器。
1. 一个应用可能会被部署到多个服务器上（server-1, server-2, ..., server-n）。当有请求发送到[https://api.yourexampleapp.com](https://api.yourexampleapp.com) 时，后端的应用会拦截这个请求头部并且从认证头部中提取到 token 信息。使用这个 token 查询数据库。如果这个 token 有效并且有请求终端数据所必须的许可时，请求会继续。如果无效，会返回 403 状态码（表明一个拒绝的状态）。


基于 token 的认证在解决棘手的问题时有几个优势：

- Client Independent Services 。在基于 token 的认证，token 通过请求头传输，而不是把认证信息存储在 session 或者 cookie 中。这意味着无状态。你可以从任意一种可以发送 HTTP 请求的终端向服务器发送请求。
- CDN 。在绝大多数现在的应用中，view 在后端渲染，HTML 内容被返回给浏览器。前端逻辑依赖后端代码。这中依赖真的没必要。而且，带来了几个问题。比如，你和一个设计机构合作，设计师帮你完成了前端的 HTML，CSS 和 JavaScript，你需要拿到前端代码并且把它移植到你的后端代码中，目的当然是为了渲染。修改几次后，你渲染的 HTML 内容可能和设计师完成的代码有了很大的不同。在基于 token 的认证中，你可以开发完全独立于后端代码的前端项目。后端代码会返回一个 JSON 而不是渲染 HTML，并且你可以把最小化，压缩过的代码放到 CDN 上。当你访问 web 页面，HTML 内容由 CDN 提供服务，并且页面内容是通过使用认证头部的 token 的 API 服务所填充。
- No Cookie-Session (or No CSRF) 。CSRF 是当代 web 安全中一处痛点，因为它不会去检查一个请求来源是否可信。为了解决这个问题，一个 token 池被用在每次表单请求时发送相关的 token。在基于 token 的认证中，已经有一个 token 应用在认证头部，并且 CSRF 不包含那个信息。
- Persistent Token Store 。当在应用中进行 session 的读，写或者删除操作时，会有一个文件操作发生在操作系统的temp 文件夹下，至少在第一次时。假设有多台服务器并且 session 在第一台服务上创建。当你再次发送请求并且这个请求落在另一台服务器上，session 信息并不存在并且会获得一个“未认证”的响应。我知道，你可以通过一个粘性 session 解决这个问题。然而，在基于 token 的认证中，这个问题很自然就被解决了。没有粘性 session 的问题，因为在每个发送到服务器的请求中这个请求的 token 都会被拦截。

这些就是基于 token 的认证和通信中最明显的优势。基于 token 认证的理论和架构就说到这里。下面上实例。

这段本来想自己写，不过自己写也这些内容，节省点时间

## jwt加密和解密

JWT 代表 JSON Web Token ，它是一种用于认证头部的 token 格式。这个 token 帮你实现了在两个系统之间以一种安全的方式传递信息。出于教学目的，我们暂且把 JWT 作为“不记名 token”。一个不记名 token 包含了三部分：header，payload，signature。

header 是 token 的一部分，用来存放 token 的类型和编码方式，通常是使用 base-64 编码。

payload 包含了信息。你可以存放任一种信息，比如用户信息，产品信息等。它们都是使用 base-64 编码方式进行存储。
signature 包括了 header，payload 和密钥的混合体。密钥必须安全地保存储在服务端。

![](/css/2015-06-14/2.jpg)


nodejs实现的jwt代码

http://github.com/auth0/node-jsonwebtoken


主要3个方法

- jwt.sign
- jwt.verify
- jwt.decode

需要小心的密钥在多线程或集群下的处理。

加解密一个对象的时间，远远比查询数据库的代价小，唯一可能有的是token有效期的校验，代价极其小。

## 优雅之写法

### 授权获取token

在app/routes/api/index.js里

```
// auth
router.post('/auth', function(req, res, next) {
  User.one({username: req.body.username},function(err, user){
    if (err) throw err;
    console.log(user);

    if (!user) {
        res.json({ success: false, message: '认证失败，用户名找不到' });
    } else if (user) {

      // 检查密码
      if (user.password != req.body.password) {
          res.json({ success: false, message: '认证失败，密码错误' });
      } else {
        // 创建token
        var token = jwt.sign(user, 'app.get(superSecret)', {
            'expiresInMinutes': 1440 // 设置过期时间
        });

        // json格式返回token
        res.json({
            success: true,
            message: 'Enjoy your token!',
            token: token
        });
      }
    }
  });
});
```

- post请求
- 地址http://127.0.0.1:3019/api/auth
- 参数"username=sang&password=000000"


测试

    curl -d "username=sang&password=000000" http://127.0.0.1:3019/api/auth

返回

    {"success":true,"message":"Enjoy your token!","token":"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJfaWQiOiI1NTc4MzJkZjk0ZTFjN2YyMDJmYTVlNGUiLCJ1c2VybmFtZSI6InNhbmciLCJwYXNzd29yZCI6IjAwMDAwMCIsImF2YXRhciI6IiIsInBob25lX251bWJlciI6IiIsImFkZHJlc3MiOiIiLCJfX3YiOjB9.Wv5za6GpJSMi346o625_8FxfoM4dJ1cWNuezG10zQG4"}%


### 路由处理

在`app/routes/api/groups.js`里

```
var express = require('express');
var router = express.Router();

var $ = require('../../controllers/groups_controller');
var $middlewares = require('mount-middlewares');

router.get('/list', $middlewares.check_api_token, $.api.list);

module.exports = router;
```

核心代码

```
router.get('/list', $middlewares.check_api_token, $.api.list);
```

说明

- 使用了$middlewares.check_api_token中间件
- 核心业务逻辑在$.api.list
- 和其他的express路由用法一样，无他

### 中间件$middlewares.check_api_token

```
/*!
 * Moajs Middle
 * Copyright(c) 2015-2019 Alfred Sang <shiren1118@126.com>
 * MIT Licensed
 */

var jwt = require('jsonwebtoken');//用来创建和确认用户信息摘要
// 检查用户会话
module.exports = function(req, res, next) {
  console.log('检查post的信息或者url查询参数或者头信息');
  //检查post的信息或者url查询参数或者头信息
  var token = req.body.token || req.query.token || req.headers['x-access-token'];
  // 解析 token
  if (token) {
    // 确认token
    jwt.verify(token, 'app.get(superSecret)', function(err, decoded) {
      if (err) {
        return res.json({ success: false, message: 'token信息错误.' });
      } else {
        // 如果没问题就把解码后的信息保存到请求中，供后面的路由使用
        req.api_user = decoded;
        console.dir(req.api_user);
        next();
      }
    });
  } else {
    // 如果没有token，则返回错误
    return res.status(403).send({
        success: false,
        message: '没有提供token！'
    });
  }
};
```

这个很容易解释，只要参数有token或者头信息里有x-access-token，我们就认定它是一个api接口，

校验通过了，就把token的decode对象，也就是之前加密的用户对象返回来，保存为`req.api_user`

### 业务代码

在`app/controllers/groups_controller.js`里

```
exports.api = {
  list: function (req, res, next) {
    console.log(req.method + ' /groups => list, query: ' + JSON.stringify(req.query));
  
    var user_id = req.api_user._id;
    
    Group.query({ower_id: user_id}, function(err, groups){
      console.log(groups);
      res.json({
        data:{
          groups : groups
        },
        status:{
          code  : 0,
          msg   : 'success'
        }
      })
    });
  }
}
```

让scaffold生成代码和api共存，清晰明了

说明一下

- req.api_user是$middlewares.check_api_token里赋值的
- 写一个下查询接口，返回json即可

### 测试接口

然后让我们来测试一下

- get请求
- url = http://127.0.0.1:3019/api/groups/list
- 参数token

```
curl http://127.0.0.1:3019/api/groups/list\?token\=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJfaWQiOiI1NTc4MzJkZjk0ZTFjN2YyMDJmYTVlNGUiLCJ1c2VybmFtZSI6InNhbmciLCJwYXNzd29yZCI6IjAwMDAwMCIsImF2YXRhciI6IiIsInBob25lX251bWJlciI6IiIsImFkZHJlc3MiOiIiLCJfX3YiOjB9.Wv5za6GpJSMi346o625_8FxfoM4dJ1cWNuezG10zQG4


  {"data":{"groups":[{"_id":"557d32a282f9ddcc76a540e8","name":"sjkljkl","desc":"2323","ower_id":"557832df94e1c7f202fa5e4e","users":"","is_public":"","__v":0},{"_id":"557d32b082f9ddcc76a540e9","name":"sjkljkl","desc":"2323","ower_id":"557832df94e1c7f202fa5e4e","users":"","is_public":"","__v":0},{"_id":"557d32f082f9ddcc76a540ea","name":"sjkljkl","desc":"2323","ower_id":"557832df94e1c7f202fa5e4e","users":"","is_public":"","__v":0},{"_id":"557d33804f5905de78e1c25a","name":"sjkljkl","desc":"2323","ower_id":"557832df94e1c7f202fa5e4e","users":"","is_public":"","__v":0},{"_id":"557d33984f5905de78e1c25b","name":"anan","desc":"2323","ower_id":"557832df94e1c7f202fa5e4e","users":"2323","is_public":"232","__v":0}]},"status":{"code":0,"msg":"success"}}  

```

### 模型，查询以及其他

模型，查询以及其他，沿用之前的东西，仍然以mongoosedao为主

- one
- all
- query

基本上够用了

如果还想玩的更high一点，可以增加一个service层，把多个model的操作放到里面。

## 总结

以后写api，可以这样玩

1) 在`app/routes/api/`目录下建立对应的api文件，比如groups.js，topics.js，users.js等

2) 然后在对应的controller里，增加

```
exports.api = {
  aa:function(req, res, next){
    var user_id = req.api_user._id;
  },
  bb:function(req, res, next){
    var user_id = req.api_user._id;
  }
}
```

3) 简单写点模型的查询方法就可以了

是不是很简单？

- 使用mount-routes自动挂载routes
- 使用mongoosedao更简单的接口

如果以后再提供生成器呢？

想想就很美好，美好就继续美好吧~


全文完

欢迎关注我的公众号【node全栈】

![](/css/node全栈-公众号.png)
