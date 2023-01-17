## 欢迎
Sprouts100项目是一个单周期RISC-V处理器原型，使用verilog编写，实现RV32IM(乘除法使用单周期的行为描述，所以在物理实现中有巨大资源占用和延迟，仅作为扩展参考)，支持软件中断。

本项目参考了[darkriscv](https://github.com/darklife/darkriscv)和[
tinyriscv](https://github.com/liangkangnan/tinyriscv)项目，建议学习数字电路、verilog、计算机组成原理基础知识。[推荐阅读这些书籍](https://zhuanlan.zhihu.com/p/386680261)。此外本项目收本人能力有限，编写并不严谨，所以仅供学习参考使用。

## 项目文件
rtl/* 为整个处理器的verilog代码。  
ISATest/* 目录下为处理器测试文件。

## 开始

1.安装`Icarus Verilog`，查看[此文档](https://zhuanlan.zhihu.com/p/436976157)

2.安装`Python3`

3.在`ISATest`目录下使用以下命令即可运行处理器测试

```
python ISATest.py
```

## 其他
性能更好，能移植FPGA，有外设的RISC-V处理器，正在整理资料中，尽情期待。
