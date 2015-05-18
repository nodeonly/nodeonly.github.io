# 如何选择nodejs和iojs？以及性能比较


有朋友问我：

初学nodejs，但是看到很多都转移去io.js，开源中国也有份测试说io性能更好，现在两者不知如何选择，望指教


看看iojs的官网 https://iojs.org/en/index.html


1.io.js is an npm compatible platform originally based on Node.js™.

这句话的重点在于基于nodejs，且兼容npm，所以它和node是一个根

2.Weekly Update – May 15th: io.js decides to join the Node Foundation

这句话说的是io.js绝对加入node基金会

这条新闻很有意思 

https://medium.com/node-js-javascript/io-js-week-of-may-15th-9ada45bd8a28

    As a first step, we will move from iojs organization to nodejs organization and will converge joyent/node gradually. We will continue to release io.js until the convergence have done.

我们会持续发布io.js，知道收编完成。

    We will continue to release io.js until the convergence have done.

我们可以这样理解

- 收编完成之后，还是要会回归node主分支的
- 我们是斗气，joyent那边孙子如果不让步，我们就继续闹

看完了这段，估计大家已经知道怎么选择了

- iojs早晚是要合并到nodejs里的，只是时间和形式的问题
- 如果各位看看iojs的文档，它和nodejs的接口大部分是一样的，所以很少会有地雷


下面给出一篇英文比较iojs和node的性能的文章，如果看不懂，看图就够了

先给出node自己的0.10和0.12的比较

![](/css/2015-05-20/0.1.png)

![](/css/2015-05-20/0.2.png)


## Performance Showdown: Node.js vs. io.js v2.0.0

We noted with some interest the recent announcement of the io.js v2.0.0 release candidate. This community fork of node.js promises a supported version of the V8 engine, along with a greatly increased frequency of commits to master vs. the parent project.

As we’ve mentioned before, we’re keen on these developments as Node.js powers the Raygun API nodes, and ensuring these can handle the highest loads with the lowest possible response times is crucial to providing a great service to our users. A previous blog post benchmarked Node.js vs. io.js, and with the advent of the V2 release of the latter, we’d like to revisit those benchmarks to see how it stacks up in various situations.


## The set up 

Same as before, the following are synthetic micro-benchmarks, caveat emptor, huge grain of salt, etc. However, the charts do provide some interesting food for thought, and may provide a springboard for you to perform your own real-world tests, and potentially gain a significant speedup.

The benchmarks were conducted with identical runs through ApacheBench on a 64-bit Ubuntu VM. The configuration was 20,000 requests with a concurrency level of 100, and the test results were averaged over five runs of this.

We benchmarked two versions of node, and two versions of io.js. For node, v0.10.38 (the last release of the .10 branch) was compared against v0.12.2 (the absolute latest version of node.js).

For io.js, we compared v1.8.1, the last release on the 1.x branch against the newest v2.0.0 release.



## Raw JSON response

This test involved created a simple server with the http module, and setting it to return a JSON payload on request. The results were:

![](/css/2015-05-20/1.png)

What is interesting to note is the performance drop from node 0.10 to 0.12, which io.js corrects on the 1.x branch – but then dominates with v2.0.0.

When sending a raw response, in this benchmark io.js v2.0.0 has a 14% speedup over node 0.12! They’ve even managed a 5% speedup over their own previous release. Not bad at all, but there’s more we can test.

## Express.js

Express was and is still a very popular choice for quickly getting the backend of a web application up and running. Last time we documented some of the performance hit you take with it, but let’s see how it does under node 0.12 vs io.js v2.0.0:

![](/css/2015-05-20/2.png)

There’s a 4.5% speedup when running this test on io.js v2.0.0 – pretty good for an older framework (considering how fast the JS ecosystem is moving)!

## Koa.js on Node vs io.js

Many newer frameworks are competing for mindshare in the JS micro web framework space, however – we benchmarked some popular ones previously. One which we missed was Koa.js, which was in fact made by the authors of Express.js.

One of the huge benefits with Koa is that you can build code using ES6 features – including generators and the yield syntax which enable asynchronous code (no more callback hell). This benchmark was written using generators and run with the node --harmony flag enabled. The logic involved a simple bit of routing, and set the response to be an HTML fragment.

Let’s see how Koa does running on Node vs. io.js:

![](/css/2015-05-20/3-2.png)

A 14.8% speedup from Node to the latest version of io.js – certainly worthy of note. If you’re looking at one of the latest generation of JS backend frameworks, it certainly pays to give io.js a look as out-of-the-box you get some rather impressive perf improvements. When running a cluster of VMs using the Node stack, depending on scale, that speedup may result in several fewer boxes needed and correspondingly less infrastructure costs – all for free.


## 总结

一句话，iojs性能比较nodejs好，看好nodejs的发展。


欢迎关注我的公众号【node全栈】

![](/css/node全栈-公众号.png)


