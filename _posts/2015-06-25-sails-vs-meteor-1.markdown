---
layout: post
title: "sails vs meteor"
description: ""
keywords: ""
category: 
tags: []
---


看一下sails的特性

- http://www.sailsjs.org/#!/features

## 安装

    npm install -g sails

很简单就可以安装了。

## 看一下它的帮助

     sails --help

      Usage: sails [command]

      Commands:

        version               
        lift [options]        
        new [options] [path_to_new_app]
        generate              
        console               
        consle                
        consloe               
        c                     
        www                   
        debug                 
        configure             
        help                  
        *                     

      Options:

        -h, --help     output usage information
        -v, --version  output the version number
        --silent       
        --verbose      
        --silly  

这是它的cli的全部功能


- new 是根据模板创建项目
- generate 是教授叫生成
- lift 是启动服务器

了解这3个基本上就可以了。

如果你想进一步了解，可以继续看help

     sails lift --help

      Usage: lift [options]

      Options:

        -h, --help     output usage information
        --prod         
        --port [port]  

## 创建一个项目看看

    sails new helloworld
    cd helloworld 
    sails lift

我们需要看一下它的目录结构

    ➜  helloworld  tree -L 2    
    .
    ├── Gruntfile.js
    ├── README.md
    ├── api
    │   ├── controllers
    │   ├── models
    │   ├── policies
    │   ├── responses
    │   └── services
    ├── app.js
    ├── assets
    │   ├── favicon.ico
    │   ├── images
    │   ├── js
    │   ├── robots.txt
    │   ├── styles
    │   └── templates
    ├── config
    │   ├── blueprints.js
    │   ├── bootstrap.js
    │   ├── connections.js
    │   ├── cors.js
    │   ├── csrf.js
    │   ├── env
    │   ├── globals.js
    │   ├── http.js
    │   ├── i18n.js
    │   ├── local.js
    │   ├── locales
    │   ├── log.js
    │   ├── models.js
    │   ├── policies.js
    │   ├── routes.js
    │   ├── session.js
    │   ├── sockets.js
    │   └── views.js
    ├── node_modules
    │   ├── ejs -> /Users/sang/.nvm/v0.10.38/lib/node_modules/sails/node_modules/ejs
    │   ├── grunt -> /Users/sang/.nvm/v0.10.38/lib/node_modules/sails/node_modules/grunt
    │   ├── grunt-contrib-clean -> /Users/sang/.nvm/v0.10.38/lib/node_modules/sails/node_modules/grunt-contrib-clean
    │   ├── grunt-contrib-coffee -> /Users/sang/.nvm/v0.10.38/lib/node_modules/sails/node_modules/grunt-contrib-coffee
    │   ├── grunt-contrib-concat -> /Users/sang/.nvm/v0.10.38/lib/node_modules/sails/node_modules/grunt-contrib-concat
    │   ├── grunt-contrib-copy -> /Users/sang/.nvm/v0.10.38/lib/node_modules/sails/node_modules/grunt-contrib-copy
    │   ├── grunt-contrib-cssmin -> /Users/sang/.nvm/v0.10.38/lib/node_modules/sails/node_modules/grunt-contrib-cssmin
    │   ├── grunt-contrib-jst -> /Users/sang/.nvm/v0.10.38/lib/node_modules/sails/node_modules/grunt-contrib-jst
    │   ├── grunt-contrib-less -> /Users/sang/.nvm/v0.10.38/lib/node_modules/sails/node_modules/grunt-contrib-less
    │   ├── grunt-contrib-uglify -> /Users/sang/.nvm/v0.10.38/lib/node_modules/sails/node_modules/grunt-contrib-uglify
    │   ├── grunt-contrib-watch -> /Users/sang/.nvm/v0.10.38/lib/node_modules/sails/node_modules/grunt-contrib-watch
    │   ├── grunt-sails-linker -> /Users/sang/.nvm/v0.10.38/lib/node_modules/sails/node_modules/grunt-sails-linker
    │   ├── grunt-sync -> /Users/sang/.nvm/v0.10.38/lib/node_modules/sails/node_modules/grunt-sync
    │   ├── include-all -> /Users/sang/.nvm/v0.10.38/lib/node_modules/sails/node_modules/include-all
    │   ├── rc -> /Users/sang/.nvm/v0.10.38/lib/node_modules/sails/node_modules/rc
    │   ├── sails -> /Users/sang/.nvm/v0.10.38/lib/node_modules/sails
    │   └── sails-disk -> /Users/sang/.nvm/v0.10.38/lib/node_modules/sails/node_modules/sails-disk
    ├── package.json
    ├── tasks
    │   ├── README.md
    │   ├── config
    │   ├── pipeline.js
    │   └── register
    └── views
        ├── 403.ejs
        ├── 404.ejs
        ├── 500.ejs
        ├── homepage.ejs
        └── layout.ejs

    36 directories, 29 files


## 目录说明

app.js是入口，和express类似，但你看不到任何express的影子，它把东西都抽象到module里了，一般人看起来是有点难于理解的。

自己的代码要写在api目录里

    ├── api
    │   ├── controllers
    │   ├── models
    │   ├── policies
    │   ├── responses
    │   └── services

而rails是在app目录里。sails放到api里，可能是现在写api比较多，2点好处

- 前后端分离
- 为移动端提供api

这命名也是比较好理解的

- controllers和models是mvc里的m和c
- services 一般是多model相关的业务操作，它只在controller里调用
- responses比较有意思，它实际上是给res服务器响应对象增加方法，比如定义个aaa方法，你就可以res.aaa()了，对于扩展res是有好处的，算一个小亮点
- policies 是权限控制部分，说白了也还是中间件，config.policies.js里声明权限，相信会玩死很多人，简单的acl还不如自己写

至此，核心的特性已经从目录看的差不多了。

## node_modules

一般项目里做模块依赖，很烦。

rails里的bundle install也很烦。。。

但是sails利用软连接，把依赖的模块放到自己的npm安装目录，然后创建软连接，这样就可以在sails new之后，里面启动服务器，无需安装任何模块，这一点还是值得借鉴的

## views

目录和express一样，它的默认模板引擎是ejs

    /**
     * View Engine Configuration
     * (sails.config.views)
     *
     * Server-sent views are a classic and effective way to get your app up
     * and running. Views are normally served from controllers.  Below, you can
     * configure your templating language/framework of choice and configure
     * Sails' layout support.
     *
     * For more information on views and layouts, check out:
     * http://sailsjs.org/#!/documentation/concepts/Views
     */

    module.exports.views = {
      engine: 'ejs',
      layout: 'layout',
      partials: false
    };

各取所需吧，爱用啥用啥，比如又要掀起一场口水打仗了。。。。

## assets

asset pipeline其实最早也是rails里的概念，可以将JS和CSS合并和压缩

打开package.json

    "grunt": "0.4.2",
    "grunt-contrib-clean": "~0.5.0",
    "grunt-contrib-coffee": "~0.10.1",
    "grunt-contrib-concat": "~0.3.0",
    "grunt-contrib-copy": "~0.5.0",
    "grunt-contrib-cssmin": "~0.9.0",
    "grunt-contrib-jst": "~0.6.0",
    "grunt-contrib-less": "0.11.1",
    "grunt-contrib-uglify": "~0.4.0",
    "grunt-contrib-watch": "~0.5.3",
    "grunt-sails-linker": "~0.9.5",
    "grunt-sync": "~0.0.4",
    
从这里基本可以看出它的功能

- js支持coffeescript
- css支持less
- 常用grunt操作，clean是清理，concat是合并，copy是复制，cssmin是压缩css，uglify是压缩js，watch是检测文件变动，sync应该是类似livereload之类的模块

后来发现它的文档里也有

Here are a few things that the default Grunt configuration in Sails does to help you out:

- Automatic LESS compilation
- Automatic JST compilation
- Automatic Coffeescript compilation
- Optional automatic asset injection, minification, and concatenation
- Creation of a web ready public directory
- File watching and syncing
- Optimization of assets in production

多了一个jst编译，是`grunt-contrib-jst`做的事儿，其他大致一样

默认它是没有grunt-cli模块的,需要自己安装

    npm install -g grunt-cli
    
然后执行grunt命令

    ➜  helloworld  grunt       
    Running "clean:dev" (clean) task
    Cleaning .tmp/public...OK

    Running "jst:dev" (jst) task
    >> Destination not written because compiled files were empty.

    Running "less:dev" (less) task
    File .tmp/public/styles/importer.css created: 0 B → 619 B

    Running "copy:dev" (copy) task
    Copied 3 files

    Running "coffee:dev" (coffee) task

    Running "sails-linker:devJs" (sails-linker) task
    padding length 4
    File "views/layout.ejs" updated.

    Running "sails-linker:devStyles" (sails-linker) task
    padding length 4
    File "views/layout.ejs" updated.

    Running "sails-linker:devTpl" (sails-linker) task
    padding length 4
    File "views/layout.ejs" updated.

    Running "sails-linker:devJsJade" (sails-linker) task

    Running "sails-linker:devStylesJade" (sails-linker) task

    Running "sails-linker:devTplJade" (sails-linker) task

    Running "watch" task
    Waiting...

这里就是grunt的tasks了，没有啥可说的，我不是很喜欢grunt，我更喜欢gulp，sails默认是grunt，但文档里有有gulp版本的，可以去试试

另外要说明的是上线的时候，静态资源处理

- 要么cdn
- 要么nginx反向代理

这东西的价值就非常好了。

## config

太多了，蛋疼。。。。


## console

    sails console
    
是通过命令行来处理数据的，一般简单测试会用

测试模型以及orm方法还是很爽的


## 来个例子玩玩吧

生成controller玩玩

    sails generate controller comment create destroy tag like

生成的代码

    /**
     * CommentController
     *
     * @description :: Server-side logic for managing comments
     * @help        :: See http://sailsjs.org/#!/documentation/concepts/Controllers
     */

    module.exports = {
	


      /**
       * `CommentController.create()`
       */
      create: function (req, res) {
        return res.json({
          todo: 'create() is not implemented yet!'
        });
      },


      /**
       * `CommentController.destroy()`
       */
      destroy: function (req, res) {
        return res.json({
          todo: 'destroy() is not implemented yet!'
        });
      },


      /**
       * `CommentController.tag()`
       */
      tag: function (req, res) {
        return res.json({
          todo: 'tag() is not implemented yet!'
        });
      },


      /**
       * `CommentController.like()`
       */
      like: function (req, res) {
        return res.json({
          todo: 'like() is not implemented yet!'
        });
      }
    };

这种意义不是很大。。。


生成模型

    sails generate model user name:string email:string password:string

基于Waterline的，除了可以适配多个db外，没看出啥特别的，写法一点也不好


如果直接生成api呢

    ➜  helloworld  sails generate api sssd sdf jklsdf werjk jlksd sd 
    info: Created a new api!


擦，生成SssdController，每一个属性生成一个方法

Sssd model里只有属性对。。。。哭了

另外把路由配置在config.routes.js里，声明式做法也蛮蛋疼的，太麻烦了。。。。

另外说基于blueprints的restful api，恕我愚钝，没太看明白

难道

     sails generate api dentist
     
所有的代码都隐掉，你无法做任何修改么？

## orm

- 强大的关联
- console 调试

如果一个orm，在js的语法下，兼容Any database，你说能不恶心么？把nosql和rdbms搞到一起，Waterline也是醉了。。。

他们还自己吹牛

- activerecord
- hibernate

类的。。。

凑合用吧

## 总结

sails能做到这样已经很不错了，有很多点都是和rails概念类似，也很用心

但出于js语法以及各种db等，还是有很多难受的地方

项目选型思考

- 如果有熟悉rails思想的人可以考虑用
- 如果有大牛可以用
- 如果是新手或者无人解决框架问题，还是老老实实的express吧


全文完

欢迎关注我的公众号【node全栈】

![](/css/node全栈-公众号.png)
