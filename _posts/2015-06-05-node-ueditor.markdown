---
layout: post
title: "Nodejs ueditor"
description: ""
keywords: ""
category: 
tags: []
---

ueditor是一个所见即所得的编辑器，baidu那些人写的，还不错

http://ueditor.baidu.com/website/


## node版本后台

可以在这里找到，http://ueditor.baidu.com/website/thirdproject.html

**Node.js:ueditor**


可你让您的UEditor 兼容nodejs。Node.js:ueditor@0.0.4以及更高版本,支持图片上传，图片批量管理等。您可以通过npm install ueditor 直接安装此插件。项目代码已经发放到github上，欢迎关注此项目。

源码地址： https://github.com/netpi/ueditor


## 服务器端用法


    var bodyParser = require('body-parser')
    var ueditor = require("ueditor")
    app.use(bodyParser.urlencoded({
      extended: true
    }))
    app.use(bodyParser.json());

    app.use("/ueditor/ue", ueditor(path.join(__dirname, 'public'), function(req, res, next) {
      // ueditor 客户发起上传图片请求
      if(req.query.action === 'uploadimage'){
        var foo = req.ueditor;
        var date = new Date();
        var imgname = req.ueditor.filename;

        var img_url = '/images/ueditor/';
        res.ue_up(img_url); //你只要输入要保存的地址 。保存操作交给ueditor来做
      }
      //  客户端发起图片列表请求
      else if (req.query.action === 'listimage'){
        var dir_url = '/images/ueditor/';
        res.ue_list(dir_url);  // 客户端会列出 dir_url 目录下的所有图片
      }
      // 客户端发起其它请求
      else {

        res.setHeader('Content-Type', 'application/json');
        res.redirect('/ueditor/ueditor.config.json')
    }}));


注意包得引用和配置项即可。再有就是提前创建好目录，防止报错。

## 客户端用法

步骤1： 下载ueditor解压到public，

步骤2： 修改`/ueditor/ueditor.config.js`


      window.UEDITOR_CONFIG = {

          //为编辑器实例添加一个路径，这个不能被注释
          UEDITOR_HOME_URL: URL

          // 服务器统一请求接口路径
          , serverUrl: URL + 'ue'


serverUrl必须和上面的服务器端配置的一样

步骤3：修改`/ueditor/ueditor.config.json`

主要是修改路径


更多用法，http://ueditor.baidu.com/doc

## 谨慎multer

如果你的项目使用了multer作为上传组件，那么你要小心了

一定要在multer之前加载ueditor，不然请求会被multer拦截，这是connect中间件的弊病

如果各位有兴趣，可以fork一笑ueditor，改成和multer兼容的，必然会有很多star

全文完

欢迎关注我的公众号【node全栈】

![](/css/node全栈-公众号.png)


