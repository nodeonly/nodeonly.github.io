---
layout: post
title: "pre commit用法"
description: ""
keywords: ""
category: 
tags: []
---

# pre-commit用法说明

Automatically install pre-commit hooks for your npm modules.

## 安装

	npm install --save-dev pre-commit

## 示例package.json

```
{
  "name": "xxxxx",
  "version": "1.0.0",
  "description": "xxxxx =====",
  "main": "index.js",
  "scripts": {
		"checkconflict":"ack '<<<<<<<'"
  },
  "pre-commit": [
     "checkconflict"
   ],
  "repository": {
    "type": "git",
    "url": "https://github.com/i5ting/xxxxx.git"
  },
  "author": "",
  "license": "ISC",
  "bugs": {
    "url": "https://github.com/i5ting/xxxxx/issues"
  },
  "homepage": "https://github.com/i5ting/xxxxx",
  "devDependencies": {
    "pre-commit": "0.0.9"
  }
}
```

说明

- pre-commit部分，说明依赖的scripts里的命令，比如例子我创建了一个checkconflict
- 当我们`git commit`的时候就调用pre-commit部分

它可以干啥

1. 检查冲突
1. 提交前自己先测试
1. 。。。

自己发挥吧
