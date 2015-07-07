---
layout: post
title: "从npm tips到express插件机制设计"
description: ""
keywords: ""
category: 
tags: []
---

大部分时间，我们只用到npm的install，init，publish等功能，但它设计的非常好，有很多是我们不了解的

How npm handles the "scripts" field

## 全局命令

用nodejs来写cli工具是非常爽的，我干了不少这样的事儿
  
- kp = kill by port
- je = json editor
- mh = start mongo here

核心就是在package.json里配置

    "preferGlobal": "true",
    "bin": {
      "mh": "index.js"
    },
  
即可

它的原理很简单，就是把这些命令，丢到环境变量里,等于

    mh = node /npm_install_path/index.js

如果我没猜错的话是软连接实现

    ln -s /bin/mh /npm_install_path/index.js
  
## npm link

为什么会知道它的原理呢？因为每次写cli都要发布到npmjs，然后安装，然后测试是否正确，太麻烦，如果使用测试，路径等也比较麻烦

后来发现

    npm link

会把开发代码直接在本地完成上面的事儿，爽死了

link之后，会有提示

   /Users/sang/.nvm/v0.10.38/bin/nmm -> /Users/sang/.nvm/v0.10.38/lib/node_modules/nmm/index.js
   /Users/sang/.nvm/v0.10.38/lib/node_modules/nmm -> /Users/sang/workspace/moa/nmm

如何确认它是软连接呢？

    ➜  nmm git:(master) ls -alt /Users/sang/.nvm/v0.10.38/bin/nmm
    lrwxr-xr-x  1 sang  staff  32 Jul  7 15:38 /Users/sang/.nvm/v0.10.38/bin/nmm -> ../lib/node_modules/nmm/index.js

## 常见的start，test

一般我喜欢重写start和test命令，比如


    "scripts": {
      "start": "nodemon ./bin/www",
      "test": "mocha -u bdd"
    },

通过`npm start`使用nodemon来启动express服务。

通过`npm test`来跑mocha测试。

无论从语义还是便利性上，都是不错的。

more see https://docs.npmjs.com/cli/start

## npm run

但是，npm支持命令就那么多，可能不够用，比如我要测试代码覆盖率

    "scripts": {
      "start": "npm publish .",
      "test": "./node_modules/.bin/gulp",
      "mocha": "./node_modules/.bin/mocha -u bdd",
      "cov":"./node_modules/.bin/istanbul cover ./node_modules/mocha/bin/_mocha --report lcovonly -- -R spec && cat ./coverage/lcov.info | ./node_modules/coveralls/bin/coveralls.js && rm -rf ./coverage"
    },
  
很明显没有`npm cov`命令的，那么怎么办呢？不要急，可以通过`npm run-script`来搞定

上面的scripts定义，可以这样执行

    npm run cov

对于自定义脚本，这样就可以解决这个问题，它的实现原理很简单，但却非常实用。

## pre-commit

有的时候我们有这样的需求，在提交代码之前，做一下测试，如果

    npm test && git push

这样就太麻烦了，程序员还是应该更懒一点

有没有更简单的办法呢？[pre-commit](https://github.com/observing/pre-commit)

    npm install --save-dev pre-commit

用法是在package.json里增加`pre-commit`字段，它一个数组

    {
      "name": "437464d0899504fb6b7b",
      "version": "0.0.0",
      "description": "ERROR: No README.md file found!",
      "main": "index.js",
      "scripts": {
        "test": "echo \"Error: I SHOULD FAIL LOLOLOLOLOL \" && exit 1",
        "foo": "echo \"fooo\" && exit 0",
        "bar": "echo \"bar\" && exit 0"
      },
      "pre-commit": [
        "foo",
        "bar",
        "test"
      ]
    }

像上面的定义是在 `git push`之前按顺序执行foo,bar和test，也就是相当于

  npm run foo
  npm run bar
  npm test
  git push

## install

我们最常用的npm install是把node模块里文件下载安装到node_modules里面，这个很好理解，那么如果我想要自定义安装呢？

以我们上面讲的https://github.com/observing/pre-commit，它是需要先安装pre-commit脚本，这个时候该怎么办呢？

实际上我们可以在scripts自定义install命令的

    "install": "node install.js",

在`npm install pre-commit`的时候，它会下载代码，然后他会执行install脚本里的内容。也就是说在install.js里，它可以把想做的事儿做了，脚本也好，编译c扩展也好，都非常简单

## 再论install

我们一般写模块的时候，首先都是`npm init`的，然后加大量代码，比如你要加test，你可能还有examples，甚至放大量doc，这些东西，难道让装你这个npm的人都下载么？

想想就是件恐怖的事儿

npm的解决方案和git的方案一下，git是创建`.gitignore`，npm也照做

    touch .npmignore
    
然后在里面放上想过滤的，不想用户安装时候下载的就好了

比较讨厌的是https://github.com/github/gitignore竟然没有

## 循环引用

循环引用在ios开发非常常见，即互相引用，导致无法引用计数归零，就没法清理内存，再扯就远了

看npm里，比如a模块依赖b模块，

    {
      "name": "A"
      "version": "0.1.2",
      "dependencies": {
        "B": "0.1.2"
      }
    }

安装完后

    ├── node_modules
    │   └── B
    ├── package.json
    └── README.md

如果a和b都依赖c呢？

安装后

    ├── node_modules
    │   ├── B
    │   │   ├── node_modules
    │   │   └── package.json
    │   └── C   
    ├── package.json
    └── README.md

这样b能引用c，c就不用安装了

这个问题是node_modules/B/package.json里

    {
      "name": "B"
      "version": "0.1.2",
      "dependencies": {
        "C": "0.0.1"
      },
      "scripts": {
        "postinstall": "node ./node_modules/C make"
      }
    }

在安装b之后，不会执行c的安装了，主要是路径变量，做法很简单，判断路径即可

    // node_modules/B/runMe.js
    var deps = ['C'], index = 0;
    (function doWeHaveAllDeps() {
      if(index === deps.length) {
        var C = require('C');
        C.make();
        return;
      } else if(isModuleExists(deps[index])) {
        index += 1;
        doWeHaveAllDeps();
      } else {
        setTimeout(doWeHaveAllDeps, 500);
      }
    })();

    function isModuleExists( name ) {
      try { return !!require.resolve(name); }
      catch(e) { return false }
    }

如果想试试，参考http://krasimirtsonev.com/blog/article/Fun-playing-with-npm-dependencies-and-postinstall-script

这个问题并不常见，比较少，但是`postinstall`确实让人脑洞打开的一个东西

## postinstall

如果各位熟悉mongoose的hook，一定会知道pre和post是啥意思，一般来说pre是previos之前的意思，post是之后的意思。

那么postinstall从字面上解，即安装之后要执行的回调。

看一下文档

https://docs.npmjs.com/misc/scripts

它确确实实是安装后的回调，这意味着我们可以借助npm做的更多

先看一下npm还提供了那些回调

- prepublish: Run BEFORE the package is published. (Also run on local npm install without any arguments.)
- publish, postpublish: Run AFTER the package is published.
- preinstall: Run BEFORE the package is installed
- install, postinstall: Run AFTER the package is installed.
- preuninstall, uninstall: Run BEFORE the package is uninstalled.
- postuninstall: Run AFTER the package is uninstalled.
- preversion, version: Run BEFORE bump the package version.
- postversion: Run AFTER bump the package version.
- pretest, test, posttest: Run by the npm test command.
- prestop, stop, poststop: Run by the npm stop command.
- prestart, start, poststart: Run by the npm start command.
- prerestart, restart, postrestart: Run by the npm restart command. Note: npm restart will run the stop and start scripts if no restart script is provided.

擦，太牛逼了，这货考虑的真的太全了，那么下面我们就看看如何利用npm的回调干坏事吧

## express插件机制设计

大家都知道express基于connect，有middleware中间件的概念，它本身遵循小而美的设计哲学，导致它非常精简

从express@generator来看，它就只能做点小打小闹的东西，如果要设计一个复杂的大系统，就免不了和代码结构，模块，组件等战斗

从我的角度讲，这些东西都可以理解成是业务插件，比如对于一个框架来说，用户管理就应该像ruby里的devise一样，以一个gem的形式存在，如果代码里引用，调用就好了。

gem + rails plugin机制可以做，那么express + npm也是可以的，但是我们缺少的plugin机制，本文先不讲plugin机制，先说利用npm的回调实现它的可能性

比如在一个boilerplate项目里，我们安装插件

    npm install --save moa-plugin-user
    
安装完成之后，我们需要对项目里的文件或配置也好做一个插件登记，这些东西是否可以放到postinstall里呢？

剩下的就都是nodejs代码了，大家写就好了。

## 如何学习

https://docs.npmjs.com/

文档虽好，可是不好理解啊，而且有的时候用到了才会看

对于开发而言，代码在手，天下我有，尤其nodejs的模块都是完全开放得，您看不看它都在你的项目目录里，一丝不挂。

编码之外，看看node_modules目录，打开package.json看看，如果发现有不懂的就去查一下文档，这样效果是最好的。

看模块可以挑一些比较好，开源贡献比较多的模块

从别人的代码里学到东西，这应该是最强的学习能力，是长远的，与各位共勉。


全文完

欢迎关注我的公众号【node全栈】

![](/css/node全栈-公众号.png)
