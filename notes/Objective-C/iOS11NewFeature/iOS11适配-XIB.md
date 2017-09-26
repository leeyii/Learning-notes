#iOS11适配-XIB

最近在适配过程中发现通过XIB对UI进行约束时,**safeArea**(是在iOS11适配中十分重要的, 可以通过[iOS 11 安全区域适配总结](http://www.jianshu.com/p/efbc8619d56b)这篇文章详细了解safeArea)没有起到作用.  

![](https://github.com/leeyii/Learning-notes/blob/master/image/iOSNweF_2.png)  
主要原因在与我的工程之前最低支持iOS8.0, iOS9.0是不能选择`Use Safe Area Layout Guides`这个选项的,如果在iOS9.0之前选中的话或出现![](https://github.com/leeyii/Learning-notes/blob/master/image/iOSNweF_1.png)警告.


解决方法将Builds for设置为 `iOS9.0 and Later`并选中`Use Safe Area Layout Guides`.  

并在如图位置选中箭头指向的选项(在iOS9.0之前没有这个选项)
![](https://github.com/leeyii/Learning-notes/blob/master/image/iOSNweF_3.png)

选中之后会出现Safe Area, 重新对空间添加约束(这里的约束应该以safeArea为基准)  
![](https://github.com/leeyii/Learning-notes/blob/master/image/iOSNweF_4.png)  
