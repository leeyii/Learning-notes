##copy&mutablecopy

###深拷贝（单层深拷贝/完全深拷贝） & 浅拷贝
**浅拷贝**：指针复制，源对象和副本指向的同一个内容（同一块内存），只有引用计数改变

**深拷贝**：内容复制，源对象和副本指向的是两块不同的内存，源对象引用计数不变，副本对象的引用计数为1

**单层拷贝**：针对集合，只对集合中的第一层元素进行copy操作（可能存在数组嵌套数组。。。）

**完全拷贝**：对集合中的每一层都执行copy操作

在OC中只有遵守**NSCopying**和**NSMutableCopying**协议的对象才能使用copy或mutablecopy，对象是进行深拷贝还是浅拷贝具体看协议方法是如何实现的

	 @protocol NSCopying
     
     - (id)copyWithZone:(nullable NSZone *)zone;
     
     @end
     
     @protocol NSMutableCopying
     
     - (id)mutableCopyWithZone:(nullable NSZone *)zone;
     
     @end
 
###非容器类的copy、mutablecopy
1.不可变对象copy

    NSString *str = @"hello";
    
    NSString *strCopy = str.copy;
    
    NSLog(@"%p, %p", str, strCopy);
    
    打印结果：0x106d3e068, 0x106d3e068
2.不可变对象mutablecopy

	NSString *str = @"leeyii";
    
    NSMutableString *mCopyStr = str.mutableCopy;
    
    NSLog(@"%p, %p", str, mCopyStr);
    
    [mCopyStr appendString:@"111"];
    
    打印结果：0x106d3e0a8, 0x61800006ba40
3.可变对象copy

	NSMutableString *mStr = @"lilei".mutableCopy;
    
    NSString *copyMstr = mStr.copy;
    
    NSLog(@"%p, %p", mStr, copyMstr);
    
    打印结果：0x608000069e40, 0xa000069656c696c5
4.可变对象mutablecopy

	NSMutableString *mStr = @"lilei".mutableCopy;
    
    NSMutableString *mcopyMstr = mStr.mutableCopy;
    
    NSLog(@"%p, %p", mStr, mcopyMstr);
    
    打印结果：0x608000069e40, 0x60800006a240
结论:只有不可变对象进行copy是浅拷贝，其余都是深拷贝

-
###容器类copy/mutablecoy

与非容器类类似，只有不可变对象进行copy时是浅拷贝，其余操作全部是深拷贝。

**但对容器内的元素进行拷贝时，全部是浅拷贝（指针指向的内容不变）**

如果要对集合内的元素也进行深拷贝，用下面这个方法。
`NSArray *deepCopy = [[NSArray alloc] initWithArray:arr copyItems:YES];`
如果你用这种方法深拷贝，集合里的每个对象都会收到 copyWithZone: 消息。如果集合里的对象都遵循 NSCopying 协议，那么对象就会被深拷贝到新的集合。如果对象没有遵循 NSCopying 协议，而尝试用这种方法进行深拷贝，会在运行时出错。copyWithZone: 这种拷贝方式只能够提供一层内存拷贝(one-level-deep copy)，而非真正的深拷贝。

如果要进行完全拷贝可以使用下面的方法
`NSArray *trueDeepCopyArray = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:oldArray]];`

参考文档

[iOS 集合的深拷贝与浅拷贝](http://www.jianshu.com/p/eb1b732b737d)