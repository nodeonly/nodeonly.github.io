---
layout: post
title: "Nodejs开源项目怎么样写测试和代码测试覆盖率"
description: ""
keywords: ""
category: 
tags: []
---

https://github.com/baoshan/wx 是一个不错的微信应用框架，接口和网站做的也不错，和wechat-api是类似的项目

群里有人问哪个好

朴灵说：“不写测试的项目都不是好项目”

确实wx目前还没有测试，对于一个开源项目来说，没有测试和代码覆盖率是不完善的，而且从技术选型来说，大多是不敢选的。

那么Nodejs开源项目里怎么样写测试和代码测试覆盖率呢？


## 测试

目前主流的就bdd和tdd，自己查一下差异

推荐

- mocha和tape

另外Jasmine也挺有名，angularjs用它，不过挺麻烦的，还有一个选择是qunit，最初是为jquery测试写的，在nodejs里用还是觉得怪怪的。

如果想简单可以tap，它和tape很像，下文会有详细说明

### mocha

mocha是tj写的

https://github.com/mochajs/mocha

    var assert = require("assert")
    describe('truth', function(){
      it('should find the truth', function(){
        assert.equal(1, 1);
      })
    })
    

断言风格，这里默认是assert，推荐使用chaijs这个模块，它提供3种风格

- Should
- Expect
- Assert

rspec里推荐用expect，其实看个人习惯

比较典型一个mocha例子

    var assert = require('chai').assert;
    var expect = require('chai').expect;
    require('chai').should();


    describe('Test', function(){
    	before(function() {
        // runs before all tests in this block
		
      })
      after(function(){
        // runs after all tests in this block
      })
      beforeEach(function(){
        // runs before each test in this block
      })
      afterEach(function(){
        // runs after each test in this block
      })
	
      describe('#test()', function(){
        it('should return ok when test finished', function(done){
          assert.equal('sang_test2', 'sang_test2');
          var foo = 'bar';
          expect(foo).to.equal('bar');
          done()
        })
      })
    })

说明

- 理解测试生命周期
- 理解bdd测试写法

单元测试需要的各个模块说明

- mocha（Mocha is a feature-rich JavaScript test framework running on node.js and the browser, making asynchronous testing simple and fun.）
- chai（Chai is a BDD / TDD assertion library for node and the browser that can be delightfully paired with any javascript testing framework.）
- sinon（Standalone test spies, stubs and mocks for JavaScript.）
- zombie (页面事件模拟Zombie.js is a lightweight framework for testing client-side JavaScript code in a simulated environment. No browser required.)
- supertest(接口测试 Super-agent driven library for testing node.js HTTP servers using a fluent API)


更多的看http://nodeonly.com/2014/11/24/mongoose-test.html


如果你想真正的玩敏捷，从用户故事开始，那么下面这2个库非常必要

- http://vowsjs.org/
- https://github.com/cucumber/cucumber-js

啊，黄瓜。。。。

### tape：像代码一样跑测试


tape是substack写的测试框架

https://github.com/substack/tape


    var test = require('tape').test;
    test('equivalence', function(t) {
        t.equal(1, 1, 'these two numbers are equal');
        t.end();
    });


tape是非常简单的测试框架，核心价值观是”Tests are code”，所以你可以像代码一样跑测试，

比如

    node test/test.js
    
写个脚本就无比简单了。当然如果你想加'test runner' 库也有现成的。
 
### The Test Anything Protocol

TAP全称是[Test Anything Protocol](https://en.wikipedia.org/wiki/Test_Anything_Protocol)

它是可靠性测试的一种（tried & true）实现

从1987就有了，有很多语言都实现了。


它说白点就是用贼简单的方式来格式化测试结果，比如


    TAP version 13
    # equivalence
    ok 1 these two numbers are equal

    1..1
    # tests 1
    # pass  1

    # ok

比如node里的实现https://github.com/isaacs/node-tap


    var tap = require('tap')

    // you can test stuff just using the top level object.
    // no suites or subtests required.

    tap.equal(1, 1, 'check if numbers still work')
    tap.notEqual(1, 2, '1 should not equal 2')

    // also you can group things into sub-tests.
    // Sub-tests will be run in sequential order always,
    // so they're great for async things.

    tap.test('first stuff', function (t) {
      t.ok(true, 'true is ok')
      t.similar({a: [1,2,3]}, {a: [1,2,3]})
      // call t.end() when you're done
      t.end()
    })

一定要区分tap和tape，不要弄混了


## 科普一下什么是CI

科普一下，CI = Continuous integration 持续集成

Martin Fowler对持续集成是这样定义的:


持续集成是一种软件开发实践，即团队开发成员经常集成他们的工作，通常每个成员每天至少集成一次，也就意味着每天可能会发生多次集成。每次集成都通过自动化的构建（包括编译，发布，自动化测试)来验证，从而尽快地发现集成错误。许多团队发现这个过程可以大大减少集成的问题，让团队能够更快的开发内聚的软件。

它可以

- 减少风险
- 减少重复过程
- 任何时间、任何地点生成可部署的软件
- 增强项目的可见性
- 建立团队对开发产品的信心

要素

1.统一的代码库
2.自动构建
3.自动测试
4.每个人每天都要向代码库主干提交代码
5.每次代码递交后都会在持续集成服务器上触发一次构建
6.保证快速构建
7.模拟生产环境的自动测试
8.每个人都可以很容易的获取最新可执行的应用程序
9.每个人都清楚正在发生的状况
10.自动化的部署

也就是说，测试不通过不能部署，只有提交到服务器上，就可以自动跑测试，测试通过后，就可以部署到服务器上了（注意是"staging", 而非"production"）。

一般最常的ci软件是jenkins

举个大家熟悉的例子iojs开发中的持续集成就是用的jenkins

https://jenkins-iojs.nodesource.com/

![](/css/2015-06-26/4.png)


jenkins是自建环境下用的比较多，如果是开源项目，推荐travis-ci

https://travis-ci.org/

对开源项目做持续集成是免费的（非开源的好贵），所以在github集成的基本是最多的。

对nodejs支持的也非常好。

举2个例子

- express  https://travis-ci.org/strongloop/express
- koa      https://travis-ci.org/koajs/koa

## 测试报告

近年随着tdd/bdd，开源项目，和敏捷开发的火热，程序员们不再满足说，我贡献了一个开源项目

要有高要求，我要加测试

要有更高要求，我要把每一个函数都测试到，让别人相信我的代码没有任何问题

上一小节讲的ci，实际上解决了反复测试的自动化问题。但是如何看我的程序里的每一个函数都测试了呢？

答案是测试覆盖率

在nodejs里，推荐[istanbul](https://github.com/gotwarlost/istanbul)

Istanbul - 官方介绍 a JS code coverage tool written in JS

它可以通过3种途径生成覆盖报告

- cli
- 代码
- gulp插件

安装

    $ npm install -g istanbul
    
执行

    $ istanbul cover my-test-script.js -- my test args

它会生成`./coverage`目录，这里面就是测试报告


比如我的项目里

    ./node_modules/.bin/istanbul cover ./node_modules/mocha/bin/_mocha --report lcovonly
        #MongooseDao()
          ✓ should return ok when record create
          ✓ should return ok when record delete fixture-user
          ✓ should return ok when record deleteById
          ✓ should return ok when record removeById
          ✓ should return ok when record getById
          ✓ should return ok when record getAll
          ✓ should return ok when record all
          ✓ should return ok when record query


      8 passing (50ms)

    =============================================================================
    Writing coverage object [/Users/sang/workspace/moa/mongoosedao/coverage/coverage.json]
    Writing coverage reports at [/Users/sang/workspace/moa/mongoosedao/coverage]
    =============================================================================

    =============================== Coverage summary ===============================
    Statements   : 47.27% ( 26/55 )
    Branches     : 8.33% ( 1/12 )
    Functions    : 60% ( 9/15 )
    Lines        : 47.27% ( 26/55 )
    ================================================================================

默认，它会生成coverage.json和Icov.info，如果你想生成html也可以的。

比如说，上面的结果47.27%是我测试覆盖的占比，即55个函数，我的测试里只覆盖了26个。

那么我需要有地方能够展示出来啊

## 实践

我们以[mongoosedao](https://github.com/moajs/mongoosedao)项目为例，介绍一下如何集成测试，ci和测试覆盖率

最终效果如图

![](/css/2015-06-26/5.png)

### npm run

package.json里定义自定义执行脚本

    "scripts": {
      "start": "npm publish .",
      "test": "./node_modules/.bin/gulp",
      "mocha": "./node_modules/.bin/mocha -u bdd",
      "cov":"./node_modules/.bin/istanbul cover ./node_modules/mocha/bin/_mocha --report lcovonly -- -R spec && cat ./coverage/lcov.info | ./node_modules/coveralls/bin/coveralls.js && rm -rf ./coverage"
    },

除了start和test外，都是自定义任务，其他都要加run命令
    
    npm run mocha
    npm run cov
    
更多见[npm-run-test教程](https://cnodejs.org/topic/54646c7f88b869cc33a97924)

### gulp watch

    var gulp = require('gulp');
    var watch = require('gulp-watch');

    var path = 'test/**/*.js';

    gulp.task('watch', function() {
      gulp.watch(['test/**/*.js', 'lib/*.js'], ['mocha']);
    });

    var mocha = require('gulp-mocha');
 
    gulp.task('mocha', function () {
        return gulp.src(path , {read: false})
            // gulp-mocha needs filepaths so you can't have any plugins before it 
            .pipe(mocha({reporter: 'spec'}));
    });


    gulp.task('default',['mocha', 'watch']);


这样就可以执行gulp的时候，当文件变动，会自动触发mocha测试，简化每次都输入npm test这样的操作。

当然你可以玩更多的gulp，如果不熟悉，参考

- [介绍gulp的一张不错的图](https://cnodejs.org/topic/5508f03d3135610a365b013d)
- [gulp实践](https://github.com/streakq/js-tools-best-practice/blob/master/doc/Gulp.md)

### 创建`.travis.yml`

项目根目录下，和package.json平级

    language: node_js
    repo_token: COVERALLS.IO_TOKEN
    services: mongodb
    node_js:
      - "0.12"
      - "0.11"
      - "0.10"
    script: npm run mocha
    after_script:
      npm run cov

说明

- 如果依赖mongo等数据库，一定要写services
- 把测试覆盖率放到执行测试之后，避免报402错误

在travis-ci.org上，github授权，添加repo都比较简单

添加之后，就可以看到，比如

https://travis-ci.org/moajs/mongoosedao

travis-ci实际上根据github的代码变动进行自动持续构建,但是有的时候它不一定更新，或者说，你需要手动选一下：

![](/css/2015-06-26/1.png)

点击`# 10 passed`,这样就可以强制它手动集成了。

其他都很简单，注意替换COVERALLS.IO_TOKEN即可。

### 创建 `.coveralls.yml`

https://coveralls.io/是一个代码测试覆盖率的网站，

nodejs下面的代码测试覆盖率，原理是通过[istanbul](https://github.com/gotwarlost/istanbul)生成测试数据，上传到coveralls网站上，然后以badge的形式展示出来

比如

[![Coverage Status](https://coveralls.io/repos/moajs/mongoosedao/badge.png)](https://coveralls.io/r/moajs/mongoosedao)


具体实践和travis-ci类似，用github账号登陆，然后添加repo，然后在项目根目录下，和package.json平级，增加`.coveralls.yml`

    service_name: travis-pro
    repo_token: 99UNur6O7ksBqiwgg1NG1sSFhmu78A0t7

在上，第一次添加repo，显示的是“SET UP COVERALLS”，里面有token，需要放到`.coveralls.yml`里，

![](/css/2015-06-26/2.png)


如果成功提交了，就可以看到数据了

![](/css/2015-06-26/3.png)

### 在readme.md里增加badge

    [![Build Status](https://travis-ci.org/moajs/mongoosedao.png?branch=master)](https://travis-ci.org/moajs/mongoosedao)
    [![Coverage Status](https://coveralls.io/repos/moajs/mongoosedao/badge.png)](https://coveralls.io/r/moajs/mongoosedao)

它就会显示如下

[![Build Status](https://travis-ci.org/moajs/mongoosedao.png?branch=master)](https://travis-ci.org/moajs/mongoosedao)
[![Coverage Status](https://coveralls.io/repos/moajs/mongoosedao/badge.png)](https://coveralls.io/r/moajs/mongoosedao)



## 另外一种用Makefile的玩法实践

举例：https://github.com/node-webot/wechat-api/blob/master/Makefile

    TESTS = test/*.js
    REPORTER = spec
    TIMEOUT = 20000
    ISTANBUL = ./node_modules/.bin/istanbul
    MOCHA = ./node_modules/mocha/bin/_mocha
    COVERALLS = ./node_modules/coveralls/bin/coveralls.js

    test:
    	@NODE_ENV=test $(MOCHA) -R $(REPORTER) -t $(TIMEOUT) \
    		$(MOCHA_OPTS) \
    		$(TESTS)

    test-cov:
    	@$(ISTANBUL) cover --report html $(MOCHA) -- -t $(TIMEOUT) -R spec $(TESTS)

    test-coveralls:
    	@$(ISTANBUL) cover --report lcovonly $(MOCHA) -- -t $(TIMEOUT) -R spec $(TESTS)
    	@echo TRAVIS_JOB_ID $(TRAVIS_JOB_ID)
    	@cat ./coverage/lcov.info | $(COVERALLS) && rm -rf ./coverage

    test-all: test test-coveralls

    .PHONY: test

我个人更喜欢npm+gulp的写法，总是有一种make是c里古老的东东。。。

## 总结

本文讲了

- nodejs里常用框架
  - mocha
  - tape
  - tap
  - 前沿技术：cucumber和vowsjs
- 科普一下CI
- 测试报告
  - istanbul
- 实践
  - gulp + npm run
  - mocha
  - travis-ci
  - coveralls
- 介绍了基于makefile的另一种玩法


全文完

欢迎关注我的公众号【node全栈】

![](/css/node全栈-公众号.png)
