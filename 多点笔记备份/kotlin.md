# kotlin

!! ： 如果为空，则抛出异常


//kotlin:
a?.run()
 
//与java相同:
if(a!=null){
 a.run();
}


//kotlin:
a!!.run()

//与java相同: 
if(a!=null){
 a.run();
}else{
 throw new KotlinNullPointException();
}


## 
let： 使用it替代object对象去访问其公有的属性 & 方法

also：
	类似let函数，但区别在于返回值：
	let函数：返回值 = 最后一行 / return的表达式
	also函数：返回值 = 传入的对象的本身

with： 调用同一个对象的多个方法 / 属性时，可以省去对象名重复，直接调用方法名 / 属性即可

run：结合了let、with两个函数的作用，即：

apply：
	与run函数类似，但区别在于返回值：
	run函数返回最后一行的值 / 表达式
	apply函数返回传入的对象的本身



