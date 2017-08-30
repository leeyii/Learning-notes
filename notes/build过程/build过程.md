#Build 过程

当我使用Xcode点击运行按钮到程序运行起来发生了什么?

##Build日志
我随便找了一个工程编译了一下, 可以再工程中如图地方看到log文件.
![](/Users/lijie/Desktop/Snip20170830_2.png)
默认情况下，上面的 Xcode 界面中隐藏了大量的信息，我们通过选择任务，然后点击右边的展开按钮，就能看到每个任务的详细信息。另外一种可选的方案就是选中列表中的一个或者多个任务，然后选择组合键 Cmd-C，这将会把所有的纯文本信息拷贝至粘贴板。最后，我们还可以选择 Editor 菜单中的 "Copy transcript for shown results"，以此将所有的 log 信息拷贝到粘贴板中。

注意观察输出的 log 信息，首先会发现 log 信息被分为不同的几大块，它们与我们工程中的targets相互对应着：

	Build target FMDB of project Pods with configuration Debug
	...
	Build target Masonry of project Pods with configuration Debug
	...
	Build target ReactiveCocoa of project Pods with configuration Debug
	...
	...
	Build target Pods-Text of project Pods with configuration Debug
	...
	Build target Text of project Text with configuration Debug
	
针对工程中的每个 target，Xcode 都会执行一系列的操作，将相关的源码，根据所选定的平台，转换为机器可读的二进制文件。

接下来分析每个target中的log信息, 每一个任务都有一个名字

	ProcessPCH ...
	CompileC ...
	Libtool ...
	CpHeader ...

顾名思义：ProcessPCH 预处理头文件,CompileC 用来编译 .m 和 .c 文件，Libtool 用来从目标文件中构建 library，CpHeader拷贝头文件.

将每个任务在展开详细分析,可以了解任务更多的信息,在这里就不详细介绍了.

---

Xcode 是如何知道哪些任务需要被执行？不要急,接着往下看.

##Build过程的控制


![](/Users/lijie/Desktop/Snip20170831_3.png)

我们选中一个project会在 project editor 顶部显示出 6 个 tabs：General, Capabilities, Info, Build Settings, Build Phases 以及 Build Rules。
后面的三个选项与build过程紧密相连.