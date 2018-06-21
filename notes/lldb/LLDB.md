# LLDB

> LLDB 是一个有着 REPL 的特性和 C++ ,Python 插件的开源调试器。LLDB 绑定在 Xcode 内部，存在于主窗口底部的控制台中。调试器允许你在程序运行的特定时暂停它，你可以查看变量的值，执行自定的指令，并且按照你所认为合适的步骤来操作程序的进展

## 设置断点

![](../../image/1529559884411.jpg)

在代码框左侧可以设置断点，当程序执行到断点所在的位置是，程序会停止，这个时候我们可以对程序进行调试。

## help

在调试框内我们输入help命令，可以查看可以使用的命令及其简单的描述。

![](../../image/20180621135123.png)

如果希望看到某个命令的用法，可以在调试器内输入`help 命令`以`brankpoint`为例。

![](../../image/20180621135626.png)

学会使用help命令，可以给我们在调试的过程中提供很多帮助。

## expression

LLDB的命令遵循唯一匹配原则：假如根据前n个字母已经能唯一匹配到某个命令，则只写前n个字母等效于写下完整的命令。`expression`和`e`表示相同的命令。

如果希望修改某个值，可以使用`expression`或`e`执行语句。在程序运行的中，如果使用`e`命令改变了某个变量的值，那么在实际运行过程中这个变量也会被修改。（仅在OC中有效，在swift中修改变量的值只在调试期间生效，当继续运行程序时，变量的值实际还是原来的值。）

使用`e`声明变量时，使用`$`符号开始作为变量的第一个字符。

在`expression`命令的说有有这样一句话

> Important Note: Because this command takes 'raw' input, if you use any
     command options you must use ' -- ' between the end of the command options
     and the beginning of the raw input.

在使用这个命令的时候需要使用` -- `将实际 command options 和 实际的表达式分开以免造成歧义。

## print & po

### p

平时使用中这是我们使用最多的两个命令.

`print`可是使用`p`代替，实际上它只是` expression -- ` 的别名。

	(lldb) e -- self.view
	(UIView?) $R0 = 0x00007fa1e2407000 {
	  UIKit.UIResponder = {
	    ObjectiveC.NSObject = {}
	  }
	}
	(lldb) p self.view
	(UIView?) $R1 = 0x00007fa1e2407000 {
	  UIKit.UIResponder = {
	    ObjectiveC.NSObject = {}
	  }
	}

上面两个代码效果完全相同。

### po


在OC和swift中所有的对象都是用指针代表的（除了某些特殊的对象，这里不做讨论），使用`p`打印出来的都是对象的指针，而不是对象的本身，如果我们想要打印对象，可以使用` po `（它实际上是`expression -O --`的别名）。`po`打印的内容在OC和swift中是有区别的。

在OC中这样打印出来的是当前对象的`description`方法的返回值，如果没有实现回到父类中寻找，知道找到NSObject中，但是`-[NSObject description]`返回实际上也是对象的指针，和使用`p`并没有区别，所有对自定义的类，我们可以实现`description `方法来方便我们调试。

在swift中,对遵守`CustomDebugStringConvertible`协议的类或结构体，使用` po `可以自定义打印内容。

## 流程控制

当程序到达断点的时候程序就会暂停，在调试条上面会出现4个可以控制流程的按钮

![](../../image/20180621184515.png)

1. continue 按钮，继续执行直到下一个断点，在LLDB中使用`process continue`,`continue`,`c`都能有相同的作用。
2. step over 按钮， 会以黑盒的方式执行一行代码。如果所在这行代码是一个函数调用，那么就不会跳进这个函数，而是会执行这个函数，然后继续。LLDB 则可以使用 `thread step-over`，`next`，或者 `n` 命令。
3. step in 按钮， 如果当前行是函数，则会进入函数内部，如果不是，则和step over作用相同，LLDB 则可以使用 `thread step in`，`step`，或者 `s` 命令。
4. step out 按钮，如果你曾经不小心跳进一个函数，但实际上你想跳过它，常见的反应是重复的运行 n 直到函数返回。其实这种情况，step out 按钮是你的救世主。它会继续执行到下一个返回语句 (直到一个堆栈帧结束) 然后再次停止。







