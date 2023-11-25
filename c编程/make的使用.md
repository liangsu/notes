# make的使用

## 1.make的一般使用

Makefile的基本构成
```
目标文件列表 分隔符 依赖文件列表[;命令]
	[命令]
	[命令]
```

```
make -f othername
```

## 2.Makefile的文件构成

## 3.使用变量

自动变量
$@： 一个规则中的目标文件
$%: 静态文件库
$<：规则中的第一个依赖文件名
$>:  
$?:
$^:
$+:
`$*`: 目标文件去掉后缀名之后的名字



## 4.隐含规则：

```
program.o: header1.h
```
等同于：
```
program.o: program.c header1.h
	gcc -c program.o program.c
```

## 5.使用条件语句：

条件语句有：ifeq、ifneq、ifdef、ifndef

```
lib_for_gcc = -lgnu
normal_libs = 

ifeq ($(CC), gcc)
libs = $(lib_for_gcc)
else
libs = $(normal_libs)
endif

foo: foo.c
	$(CC) -o foo foo.c $(libs)
```


















