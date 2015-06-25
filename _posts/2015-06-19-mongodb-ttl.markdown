---
layout: post
title: "mongodb的ttl"
description: ""
keywords: ""
category: 
tags: []
---


TTL是 Time To Live的缩写，译为生存时间。
TTL Collection(淘汰过期数据)


MongoDB 2.2 引入一个新特性 —— TTL 集合，TTL 集合支持失效时间设置，当超过指定时间后，集合自动清除超时的文档，这用来保存一些诸如session会话信息的时候非常有用，或者存储缓存数据使用。

如果你想使用 TTL 集合，你要用到 expireAfterSeconds 选项： 

    db.ttl.ensureIndex({"Date": 1}, {expireAfterSeconds: 300})
  
## 限制

使用 TTL 集合时是有限制的： 

- 你不能创建 TTL 索引，如果要索引的字段已经在其他索引中使用
- 索引不能包含多个字段
- 索引的字段必须是一个日期的 bson 类型

如果你违反了上述三个规则，那么超时后文档不会被自动清除。

## 文档是怎么被删除的？

mongod 后台进程会实时跟踪过期的文档并删除，我们来对此进行检查测试：

首先我们创建一个索引并设置 10 秒钟后失效：

    db.ttl_collection.ensureIndex( { "Date": 1 }, { expireAfterSeconds: 10 } )
    
然后插入文档：

    db.ttl_collection.insert({"Date" : new Date()})
    
因为我们想象该文档会在 10 秒后删除，可是我在我的电脑上测试多次，结果却不太一样。

有些时候 mongod 在 18 秒后删除，有些时候是 40 秒。

为什么会这样呢？我们已经告诉 MongoDB 要在 10 秒后删除，可事实上却不是如此。 

例如，这一次是 45 秒中后才删除： 

因为 mongod 后台任务每分钟检查一次过期文档，因此在时间的处理上总有一定的差异，但这个差异不会超过 1 分钟，这也取决于 MongoDB 实例当前的负荷情况。 

## mongo session

    {
      "_id": "L3b_elXZtbDBxOkwFICHyBvfn7etKiJP",
      "session": {
        "cookie": {
          "originalMaxAge": 1800000,
          "expires": "2015-06-19T09:16:49.469Z",
          "secure": false,
          "httpOnly": true,
          "path": "/"
        },
        "current_user": {
          "_id": "55783c18ad0e6c3e1bb03399",
          "username": "kezhi",
          "password": "111111",
          "__v": 0
        }
      },
      "expires": ISODate("2015-06-19T09:16:49.524Z")
    }

好奇怪，我刚建立的session


    db.sessions.stats()
    
    
    {
        "ns" : "vsq.sessions",
        "count" : 1,
        "size" : 240,
        "avgObjSize" : 240,
        "numExtents" : 1,
        "storageSize" : 8192,
        "lastExtentSize" : 8192,
        "paddingFactor" : 1,
        "paddingFactorNote" : "paddingFactor is unused and unmaintained in 3.0. It remains hard coded to 1.0 for compatibility only.",
        "userFlags" : 1,
        "capped" : false,
        "nindexes" : 2,
        "indexDetails" : {},
        "totalIndexSize" : 16352,
        "indexSizes" : {
            "_id_" : 8176,
            "expires_1" : 8176
        },
        "ok" : 1
    }
    
    



全文完

欢迎关注我的公众号【node全栈】

![](/css/node全栈-公众号.png)
