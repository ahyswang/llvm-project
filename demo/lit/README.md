# LIT

## 简介

lit（LLVM Integrated Tester）是一个轻量化的测试框架，主要用于 LLVM 项目，但也适用于其他 C/C++/Python 项目的自动化测试。它基于文件匹配和简单的测试指令，适合运行大规模回归测试。

lit 自动查找测试目录下面下面的配置文件,没有测试文件会向上查找），并执行测试。配置文件优先查找lit.site.cfg[.py]，如果没有找到在查找lit.cfg[.py]。

## 步骤

准备相关的环境。

```
pip3 install lit 
pip3 install filecheck
```

## 参考

* 1. [MLIR](https://mlir.llvm.org/)
* 2. [LLVM LIT测试框架](https://llvm.org/docs/CommandGuide/lit.html)
* 3. [学习LLVM LIT测试框架](https://www.bilibili.com/video/BV1NSxieiEWD/?spm_id_from=333.337.search-card.all.click&vd_source=488f3f7a204cd22e1e881a38e1b4c61a)