#Build 过程

##关于build system
build system将我们的源码和资源文件转变为app.
在开发工程中当你进行以下行为时都会调用build system:

>* Build, run, test, profile, analyze, or archive your project.
>* Use Xcode Server to perform continuous integration of your projects.
>* Use the xcodebuild command-line tool outside of Xcode.

每次调用build system构建就是执行一系列有序的任务.最常见的就是 调用命令行工具编译和link源文件; 执行文件操作,例如复制文件; 或者执行自定义的文件处理,例如生成Info.plist文件

##工作流程
![](https://github.com/leeyii/Learning-notes/blob/master/notes/build%E8%BF%87%E7%A8%8B/image/bs_buildsystemworkflow_diagram.png)

1. 确定build target
2. 检索build configurations, build settings, build phases, and build rules.
3. 检查有无依赖target 或者 其他需要编译其他target
4. 准备一个完整的构建必须执行的任务列表
5. 如果额外的构建任务是可能的,准备额外的构建任务
6. 根据build phases执行构建任务,如果有必要可以创建自定义的build rules

####交互
有以下几个部分可以对build system起影响作用.

* Workspaces:用来管理多个Project.[iOS使用Workspace来管理多项目](http://www.jianshu.com/p/b6c59d8ed2c9)
* Projects
* Schemes
* Actions
* Targets
* Build settings
* Build configurations
* Build phases
* Build rules 
* Build configuration (xcconfig) files



##Build日志
我随便找了一个工程编译了一下, 可以在工程中如图地方看到log文件,这里包含就是每一个任务
![](https://github.com/leeyii/Learning-notes/blob/master/notes/build%E8%BF%87%E7%A8%8B/image/Snip20170830_2.png)
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


![](https://github.com/leeyii/Learning-notes/blob/master/notes/build%E8%BF%87%E7%A8%8B/image/Snip20170831_3.png)

我们选中一个project会在 project editor 顶部显示出 6 个 tabs：General, Capabilities, Info, Build Settings, Build Phases 以及 Build Rules。
后面的三个选项与build过程紧密相连.

####Build Phases
Build Phases 代表着将代码转变为可执行文件的最高级别规则。里面描述了 build 过程中必须执行的不同类型规则:   

* **Compile sources.** 关联可编译的源文件.这个阶段每个target只能执行一次.
* **Headers.** 为target关联公共和私有的头文件.如果构建目标是framework头文件会被复制到product中,否则会不复制到product中.这个阶段每个target只能执行一次.
* **Link binary with libraries.** 这里面列出了所有的静态库和动态库.
* **Copy bundle resources.** 关联资源,拷贝到product文件夹下.这个阶段每个target只能执行一次且这个target支持嵌入资源.
* **Copy files.** 拷贝文件到product指定的路径下.这个阶段可被执行多次
* **Run script.** 执行一个指定的脚本文件在构建过程中.这个阶段可被执行多次
* **Target dependencies.**  target 依赖项的构建。这里会告诉 build 系统，build 当前的 target 之前，必须先对这里的依赖性进行 build

####Build Rules

Build rules 指定了不同的文件类型该如何编译。一般来说，开发者并不需要修改这里面的内容。如果你需要对特定类型的文件添加处理方法，那么可以在此处添加一条新的规则。

####Build Settings

至此，我们已经了解到在 build phases 中是如何定义 build 处理的过程，以及 build rules 是如何指定哪些文件类型在编译阶段需要被预处理。在 build settings 中，我们可以配置每个任务（之前在 build log 输出中看到的任务）的详细内容。

你会发现 build 过程的每一个阶段，都有许多选项：从编译、链接一直到 code signing 和 packaging。注意，settings 是如何被分割为不同的部分 -- 其实这大部分会与 build phases 有关联，有时候也会指定编译的文件类型。

这些选项基本都有很好的文档介绍，你可以在右边面板中的 quick help inspector 或者 Build Setting Reference 中查看到。

***
**Reference:**
>[Build 过程](https://objccn.io/issue-6-1/)   
>[Build Setting Reference](https://developer.apple.com/legacy/library/documentation/DeveloperTools/Reference/XcodeBuildSettingRef/0-Introduction/introduction.html#//apple_ref/doc/uid/TP40003931-CH3-SW105)