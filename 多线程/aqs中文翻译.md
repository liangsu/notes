# juc同步框架

> 原文：《The java.util.concurrent Synchronizer Framework》
>
> 参考：https://www.cnblogs.com/dennyzhangdd/p/7218510.html

## 摘要

​        在J2SE 1.5的java.util.concurrent包（下称j.u.c包）中，大部分的同步器（例如锁，屏障等等）都是基于AbstractQueuedSynchronizer类（下称AQS类），这个简单的框架而构建的。这个框架为同步状态的原子性管理、线程的阻塞、解除阻塞以及队列提供了一种通用的机制。这篇论文主要描述了这个框架基本原理、设计、实现、用法以及性能。

## 1. 介绍

通过JCP的JSR166规范，Java的1.5版本引入了j.u.c包，这个包提供了一系列支持中等程度并发的类。

## 2. 需求



## 3. 设计和实现



## 4. 用法



## 5. 性能



## 6. 总结



## 7. 鸣谢



## 8. 参考文献







