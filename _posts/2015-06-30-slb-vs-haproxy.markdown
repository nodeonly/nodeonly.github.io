---
layout: post
title: "Nodejs负载均衡实践：haproxy，slb以及node-slb"
description: ""
keywords: ""
category: 
tags: []
---


我的线上环境是阿里云，既然阿里云有SLB，比自己运维一个要省事儿的多，事实上，自己做也真不一定做得比它好，本文试图以haproxy来解释一下slb的原理

## 目前比较流行的

目前，在线上环境中应用较多的负载均衡器硬件有F5 BIG-IP,软件有LVS，Nginx及HAProxy,高可用软件有Heartbeat. Keepalived

成熟的架构有

- LVS+Keepalived
- Nginx+Keepalived
- HAProxy+keepalived
- DRBD+Heartbeat

## HAProxy

优点

1. HAProxy是支持虚拟主机的，可以工作在4. 7层(支持多网段)；
2. 能够补充Nginx的一些缺点比如Session的保持，Cookie的引导等工作；
3. 支持url检测后端的服务器；
4. 它跟LVS一样，本身仅仅就只是一款负载均衡软件；单纯从效率上来讲HAProxy更会比Nginx有更出色的负载均衡速度，在并发处理上也是优于Nginx的；
5. HAProxy可以对Mysql读进行负载均衡，对后端的MySQL节点进行检测和负载均衡，不过在后端的MySQL slaves数量超过10台时性能不如LVS；
6. HAProxy的算法较多，达到8种；


官网 http://www.haproxy.org/ (自备梯子)

- http://cbonte.github.io/haproxy-dconv/configuration-1.5.html
- http://demo.haproxy.org/

我觉得它是所有负载软件里最简单最好用的。配置文件比nginx还简单，而且还有监控页面。

下载最新版软件 http://www.haproxy.org/download/1.5/src/haproxy-1.5.12.tar.gz


解压

    tar -zxvf haproxy-1.5.12.tar.gz
    
切换到目录

    cd haproxy-1.5.12 
    
打开readme看一下，如何安装

    make TARGET=linux26
    sudo make install


## 创建一个配置文件

    # Simple configuration for an HTTP proxy listening on port 80 on all
    # interfaces and forwarding requests to a single backend "servers" with a
    # single server "server1" listening on 127.0.0.1:8000
    global
        daemon
        maxconn 256

    defaults
        mode http
        timeout connect 5000ms
        timeout client 50000ms
        timeout server 50000ms

    frontend http-in
        bind *:80
        default_backend servers

    backend servers
        server server1 127.0.0.1:8000 maxconn 32


    # The same configuration defined with a single listen block. Shorter but
    # less expressive, especially in HTTP mode.
    global
        daemon
        maxconn 256

    defaults
        mode http
        timeout connect 5000ms
        timeout client 50000ms
        timeout server 50000ms

    listen http-in
        bind *:80
        server server1 127.0.0.1:8000 maxconn 32

## 启动

    haproxy -f test.cfg

## 查看状态

记得在配置文件里加上

    listen admin_stats
        bind 0.0.0.0:8888
        stats refresh 30s
        stats uri /stats
        stats realm Haproxy Manager
        stats auth admin:admin
        #stats hide-version

http://ip:8888/stats


## 负载均衡--调度算法

HAProxy的算法有如下8种：

- roundrobin，表示简单的轮询，这个不多说，这个是 负载均衡 基本都具备的；
-  static-rr，表示根据权重，建议关注；
- leastconn，表示最少连接者先处理，建议关注；
- source，表示根据请求源IP，建议关注；
- uri，表示根据请求的URI；
- url_param，表示根据请求的URl参数'balance url_param' requires an URL parameter name
- hdr(name)，表示根据HTTP请求头来锁定每一次HTTP请求；
- rdp-cookie(name)，表示根据据cookie(name)来锁定并哈希每一次TCP请求。


## SLB是神马

负载均衡（Server Load Balancer，简称SLB）是对多台云服务器进行流量分发的负载均衡服务。SLB可以通过流量分发扩展应用系统对外的服务能力，通过消除单点故障提升应用系统的可用性


## SLB是如何实现的

使用tengine实现的。

Tengine是由淘宝网发起的Web服务器项目。它在Nginx的基础上，针对大访问量网站的需求，添加了很多高级功能和特性。

see http://tengine.taobao.org/ 

## SLB用法

创建slb

![](/css/2015-06-30/1.png)


点击管理按钮，进入实例详情

![](/css/2015-06-30/2.png)

没啥需要改的，我们直接看服务监听功能，看看如何配置slb

- 配置端口
- 转发规则 
- 带宽
- 健康检查等

![](/css/2015-06-30/3.png)

点击编辑按钮，此时可以看到具体配置页面

![](/css/2015-06-30/4.png)


目前slb支持2种转发规则

- 轮询
- 最小连接数

轮询应该是和haproxy的roundrobin调度算法一样，表示简单的轮询

最小连接数SLB会自动判断 当前ECS 的established 来判断是否转发


配置完了slb server，下一步要设置具体slb把请求转发给哪台机器，这实际上才是最核心的的配置。

阿里云把这件事儿做的超级简单

假设我现在有一个ecs服务器为已填加

![](/css/2015-06-30/5.png)

点击【未添加的服务器】，此时会列出未加入负载池的ecs服务器 

![](/css/2015-06-30/6.png)

选中一台服务器

![](/css/2015-06-30/7.png)

点击批量添加

![](/css/2015-06-30/8.png)

配置一下权重，如果机器性能一样就配置权重一样，性能越好，权重越大

可选值【0 -- 100】

完成配置后，已添加服务器里就有了2台服务器

![](/css/2015-06-30/9.png)

保证你的服务器都启动，比如2台服务器的80端口都正常即可

此时你需要做的是把你的域名解析到slb服务器的ip地址上

## node-slb

an expressjs middleware for aliyun slb

### 缘起

http://bbs.aliyun.com/read/188736.html?page=1

2）请问健康检查发的什么请求？ head 还是 get？ 
head请求。 

如果express路由没有处理head请求的话，会触发其他路由，可能会出现请求重定向死循环

## 原理

    var debug = require('debug')('slb');

    module.exports = function (req, res, next) {
      if(req.method.toLowerCase() == 'head'){    
        debug('[ALIYUN.COM LOG]: SLB health checking....OK...');
        return res.sendStatus(200);
      }
  
      next();
    };

原理非常简单：以中间件的形式，处理一下req.method为head的适合，终止此请求即可


### 安装

    npm install --save node-slb

### 用法

    var slb = require('node-slb');

    var app = express();
    app.user(slb);

### 测试


首先启动demo的服务

    ➜  node-slb git:(master) ✗ npm start

    > node-slb@1.0.0 start /Users/sang/workspace/github/node-slb
    > cd demo && npm install && npm start


    > url@0.0.0 start /Users/sang/workspace/github/node-slb/demo
    > node ./bin/www

执行test命令，测试请求

    ➜  node-slb git:(master) ✗ npm test

    > node-slb@1.0.0 test /Users/sang/workspace/github/node-slb
    > curl -i -X HEAD http://127.0.0.1:3000

    HTTP/1.1 200 OK
    X-Powered-By: Express
    Content-Type: text/plain; charset=utf-8
    Content-Length: 2
    ETag: W/"2-d736d92d"
    Date: Mon, 29 Jun 2015 03:46:49 GMT
    Connection: keep-alive

此时，观察服务器日志

    ➜  node-slb git:(master) ✗ npm start

    > node-slb@1.0.0 start /Users/sang/workspace/github/node-slb
    > cd demo && npm install && npm start


    > url@0.0.0 start /Users/sang/workspace/github/node-slb/demo
    > DEBUG=slb node ./bin/www

    [ALIYUN.COM LOG]: SLB health checking....OK...
  
如果出现`[ALIYUN.COM LOG]: SLB health checking....OK...`说明正常。

如果想打印日志，可以DEBUG=slb，如果不想打印日志，默认即无。

## 总结

- 首先介绍了haproxy和负载均衡算法
- 介绍了阿里云slb用法
- 给出node-slb，一个express中间件

全文完

欢迎关注我的公众号【node全栈】

![](/css/node全栈-公众号.png)
