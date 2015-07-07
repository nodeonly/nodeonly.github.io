---
layout: post
title: "gulp结构化"
description: ""
keywords: ""
category: 
tags: []
---

gulp结构化是一个很大的问题，如果一直在Gulpfile.js上增加，大到一定程度上问题就来了

- 可读性差
- 莫名其妙的bug
- 测试难

有没有比好的实践呢？

## pixi

https://github.com/GoodBoyDigital/pixi.js

这个一个非常出名的 HTML 5 2D rendering engine。做游戏和一些微信超炫应用是比较好的一个技术选型。

它自己吹的是“it's fast. Really fast”。

对于一个开发来说，一定要扒出点好东西才算合格。

它的gulpfile.js


    var gulp        = require('gulp'),
        requireDir  = require('require-dir');

    // Specify game project paths for tasks.
    global.paths = {
        src: './src',
        out: './bin',

        get scripts() { return this.src + '/**/*.js'; },
        get jsEntry() { return this.src + '/index'; }
    };

    // Require all tasks in gulp/tasks, including subfolders
    requireDir('./gulp/tasks', { recurse: true });

    // default task
    gulp.task('default', ['jshint', 'build']);

代码量很小，而且jshint和build根本没看到，它是怎么加载进来的呢？

    requireDir  = require('require-dir');
    
是根据目录加载的node模块，和我常用的`require-directory`是一样的功能。

    requireDir('./gulp/tasks', { recurse: true });
    
这就很明显了，看一下gulp目录

    ➜  gulp git:(master) tree .
    .
    ├── tasks
    │   ├── build.js
    │   ├── clean.js
    │   ├── dev.js
    │   ├── jsdoc.js
    │   ├── jshint.js
    │   ├── scripts.js
    │   └── watch.js
    └── util
        ├── bundle.js
        ├── handleErrors.js
        ├── jsdoc.conf.json
        └── karma.conf.js

    2 directories, 11 files

可以说这是一个比较好的一个gulp实践

## mount-tasks

我根据上面pixi的做法，使用`require-directory`改了一个版本，没几行代码，主要是实现了指定目录，把里面的js加载成gulp 可用的 task。

### Install

    npm install --save mount-tasks

### Usages

在Gulpfile.js里


    var gulp        = require('gulp');

    // Require all tasks in vendor/tasks, including subfolders
    require('mount-tasks')(__dirname + '/tasks')

    // default task
    gulp.task('default', ['clean', 'build']);


在tasks目录，我们放2个task，结构如下

    ➜  mount-tasks git:(master) tree tasks
    tasks
    ├── build.js
    └── clean.js

    0 directories, 2 files

此时，执行gulp，就可以出发clean和build任务了。

我们简单看一下任务是如何定义的，是否足够简单

clean.js里代码（build.js和这个类似）

    var gulp    = require('gulp');

    gulp.task('clean', function () {
      console.log('clean');
    });

是不是足够简单呢？

如果你对gulp不太了解，可以看看这篇文档

https://github.com/streakq/js-tools-best-practice/blob/master/doc/Gulp.md


全文完

欢迎关注我的公众号【node全栈】

![](/css/node全栈-公众号.png)
