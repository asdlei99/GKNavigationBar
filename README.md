## GKNavigationBar
GKNavigationBarViewController的分类实现方式，耦合度底，使用更加便捷

[![Build Status](http://img.shields.io/travis/QuintGao/GKNavigationBar/master.svg?style=flat)](https://travis-ci.org/QuintGao/GKNavigationBar)
[![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://raw.githubusercontent.com/QuintGao/GKNavigationBar/master/LICENSE)
[![platform](http://img.shields.io/cocoapods/p/GKNavigationBar.svg?style=flat)](http://cocoadocs.org/docsets/GKNavigationBar)
[![languages](https://img.shields.io/badge/language-objective--c-blue.svg)](#)
[![cocoapods](http://img.shields.io/cocoapods/v/GKNavigationBar.svg?style=flat)](https://cocoapods.org/pods/GKNavigationBar)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/QuintGao/GKNavigationBar)
[![support](https://img.shields.io/badge/support-ios%208%2B-orange.svg)](#) 

## 介绍：(本框架的特性)

* 无侵入性，低耦合性
* 支持自定义导航栏样式（隐藏、透明等）
* 支持控制器开关返回手势
* 支持控制器开关全屏返回手势
* 支持控制器设置导航栏透明度，可实现渐变效果
* 完美解决UITableView，UIScrollView滑动手势冲突
* 可实现push，pop时控制器缩放效果（如：今日头条）
* 可实现左滑push一个控制器的效果（如：网易新闻）

## 使用说明

#### 1、在AppDelegate中添加导航配置

```
[GKConfigure setupDefaultConfigure]
```

#### 2、创建根导航控制器

```
UINavigationController *nav = [UINavigationController rootVC:[GKMainViewController new]];
```

#### 3、设置导航栏属性（调用即创建）

```
self.gk_navBackgroundColor = [UIColor red]
```
更多属性及方法可在demo中查看

## 版本记录
* 0.0.5 - 2020.01.02 修复某些情况下状态栏显示异常问题
* 0.0.4 - 2019.12.22 优化状态栏切换功能
* 0.0.3 - 2019.11.12 修复设置导航栏左右间距无效的问题
* 0.0.2 - 2019.11.04 优化代码，解决只调用gk_navigationItem时导航栏不出现的bug
* 0.0.1 - 2019.11.03 对GKNavigationBarViewController做了修改，使用更方便
