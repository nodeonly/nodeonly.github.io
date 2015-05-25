---
layout: post
title: "如何处理h5高清屏图片？"
description: ""
keywords: ""
category: 
tags: []
---


layzr.js 是一个很小、速度快、无依赖的，用于浏览器图片延迟加载的库。

我们找到Layzr.js官方的Github上面，dist目录发布的 layzr.min.js 仅有 2.2 KB。同时，发现 package.json 文件，没有任何的dependencies依赖。

用layzr.js进行图片延迟加载，是非常方便的。通过配置选项，实现最大化的加载速度。layzr.js对于滚动事件已去抖，以尽量减少对浏览器的压力，以确保最佳的渲染。

项目官方网站：https://github.com/callmecavs/layzr.js

如果说仅仅是图片延时加载，它不至于成为github的热门项目，下面我们来看一下技术点


## 如果区分是否是高清屏？


举个简单的例子，比如iphone从4s之后就是高清屏， 新版的苹果本也都是高清屏

layzr是这样做的：

    this._retina  = window.devicePixelRatio > 1;
    
## 关于device-pixel-ratio

device-pixel-ratio是media query一查询条件，用于获得设备的像素比。一般来说iPhone4/4s的值是2，高分辨率的Andriod设备是1.5，一般设备是1，有了这些条件，我们就可以为不同的设备提供不同分辨率的图片了。

事先假定让图片兼容以上像素比，展示一张宽高为100px的图片。首先我们需要准备三张不同分辨率的图片：当正常像素比为1时，我们载入的是正常图片100px*100px，当像素比为1.5时，载入150px*150px的图片，当像素比为2.0，载入200px*200px的图片。

来个例子

```
<html>
 <head> 
  <meta charset="utf-8" /> 
  <meta name="viewport" content="width=device-width,initial-scale=1.0,maximum-scale=1.0,user-scalable=no" /> 
  <title>利用media query让背景图适应不同分辨率的设备</title> 
  <style>
            /* 像素比为1，链入100px的图片， background-size：100% */
            .header { background: url(Logo_1.png) no-repeat; }
            /*像素比为1.5，链入150px的图片， background-size：1/1.5=66.7% */
            @media only screen and (-moz-min-device-pixel-ratio: 1.5), only screen and (-o-min-device-pixel-ratio: 3/2), only screen and (-webkit-min-device-pixel-ratio: 1.5), only screen and (min-device-pixel-ratio: 1.5) {
                .header { background: url(Logo_1-5.png) no-repeat; background-size:66.7%; }
            }
            /*像素比为2，链入200px的图片， background-size：1/2=50% */
            @media only screen and (-moz-min-device-pixel-ratio: 2), only screen and (-o-min-device-pixel-ratio: 2/1), only screen and (-webkit-min-device-pixel-ratio: 2), only screen and (min-device-pixel-ratio: 2) {
                .header { background: url(Logo_2-0.png) no-repeat; background-size: 50%;}
            }
            .w100{width:100px;height:100px;}
        </style> 
 </head>
 <body></body>
</html>
```

## 用法

看一下文档，layzr的关于retina图的用法如下：

```html
<img data-layzr="image/source" data-layzr-retina="optional/retina/source">
```

## 为什么它用data-xxx?


自定义数据属性是在HTML5中新加入的一个特性。

简单来说，自定义数据属性规范规定任何以data-开头属性名并且赋值。

自定义数据属性是为了保存页面或者应用程序的私有自定义数据，这些自定义数据属性保存进DOM中，对于整个DOM的布局和表现无任何影响，但是却可以方便操控整个网页的交互以及想要表达的效果。

最典型的例子是jquery mobile

看一下它的panel经典用法： http://demos.jquerymobile.com/1.4.5/panel/

```
<div data-role="page">

<div data-role="panel" id="mypanel">
    <!-- panel content goes here -->
</div><!-- /panel -->

<!-- header -->
<!-- content -->
<!-- footer -->

</div><!-- page -->
```

标签上都是自定义属性，每多一个属性，组合可能性会非常多，可读性比较高，但记忆成本也比较高

既然h5推荐，可以用，但不建议大量用


## 关于图片的2种用法

1. img标签src
2. background-image(url)

layzr里做成了选项

```
  // set node src or bg image
  if(node.hasAttribute(this._optionsAttrBg)) {
    node.style.backgroundImage = 'url(' + source + ')';
  }
  else {
    node.setAttribute('src', source);
  }
```

用法

```html
<img data-layzr="image/source" data-layzr-bg>
```

## 处理scroll和resize事件

对于滚动事件已去抖，尽量减少对浏览器的压力

```
Layzr.prototype._create = function() {
  // fire scroll event once
  this._requestScroll();

  // bind scroll and resize event
  window.addEventListener('scroll', this._requestScroll.bind(this), false);
  window.addEventListener('resize', this._requestScroll.bind(this), false);
};

Layzr.prototype._destroy = function() {
  // possibly remove attributes, and set all sources?

  // unbind scroll and resize event
  window.removeEventListener('scroll', this._requestScroll.bind(this), false);
  window.removeEventListener('resize', this._requestScroll.bind(this), false);
};
```

## 配置项

Layzr(options)里的options

```
  this._optionsSelector   = options.selector || '[data-layzr]';
  this._optionsAttr       = options.attr || 'data-layzr';
  this._optionsAttrRetina = options.retinaAttr || 'data-layzr-retina';
  this._optionsAttrBg     = options.bgAttr || 'data-layzr-bg';
  this._optionsAttrHidden = options.hiddenAttr || 'data-layzr-hidden';
  this._optionsThreshold  = options.threshold || 0;
  this._optionsCallback   = options.callback || null;
```

比jquery的插件的选项差，不过刚刚好用，保证代码足够精简

简单说明

- selector: 用于选定图像标签。
- attr: 用于指定data-layzr的属性
- retinaAttr: 用于指定data-layzr-retina属性
- bgAttr: 用于指定data-layzr-bg的属性
- threshold: 用于定义图像加载参数，通过屏幕高度来控制。
- callback: 当加载完成，触发事件回调。


## 源码里有2个有用的链接

// DEBOUNCE HELPERS
// adapted from: http://www.html5rocks.com/en/tutorials/speed/animations/


// OFFSET HELPER
// borrowed from: http://stackoverflow.com/questions/5598743/finding-elements-position-relative-to-the-document




欢迎关注我的公众号【node全栈】

![](/css/node全栈-公众号.png)


