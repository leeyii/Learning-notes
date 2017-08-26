#CoreText学习笔记（二）- CTRunDelegate


使用CoreText本身并不能进行图文混排， 但是可以使用CTRunDelegate在需要显示图片的位置预留出来。

##创建CTRundelegate
`CTRunDelegateRef CTRunDelegateCreate(
	const CTRunDelegateCallbacks* callbacks,
	void * __nullable refCon )`  
	`callbacks`: 包含了CTRunDelegate回调函数指针的结构体 
	
	// 销毁函数指针
	typedef void (*CTRunDelegateDeallocateCallback) (
	void * refCon );
	// 返回字形Ascent
	typedef CGFloat (*CTRunDelegateGetAscentCallback) (
	void * refCon );
	// 返回字形Descent
	typedef CGFloat (*CTRunDelegateGetDescentCallback) (
	void * refCon );
	// 返回字形Width
	typedef CGFloat (*CTRunDelegateGetWidthCallback) (
	void * refCon );
	typedef struct
	{
		CFIndex							version; 
		CTRunDelegateDeallocateCallback	dealloc; 
		CTRunDelegateGetAscentCallback	getAscent; 
		CTRunDelegateGetDescentCallback	getDescent;
		CTRunDelegateGetWidthCallback	getWidth;
	} CTRunDelegateCallbacks;
	
关于字形的Ascent等介绍在我的上篇文章[Core Text 学习笔记-基础](http://www.jianshu.com/p/611f61cd99da)

`refCon`:这个参数是一个指针类型的参数， 在回调中的参数refCon就是这个东西， 可以传一个包含这些字形信息的字典，也可以将字形信息封装成对象传进去。

下面是具体代码

	// 回调函数
	
	static void deallocCallback (void *ref) {
	    NSDictionary *dic = (__bridge_transfer NSDictionary *)(ref);
	    dic = nil;
	}
	
	static CGFloat getAscentCallback (void *ref) {
	    NSDictionary *dic = (__bridge NSDictionary *)ref;
	    return [dic[@"ascent"] floatValue];
	}
	
	static CGFloat getDecentCallback (void *ref) {
	    NSDictionary *dic = (__bridge NSDictionary *)ref;
	    return [dic[@"decent"] floatValue];
	}
	
	static CGFloat getWidthCallback (void *ref) {
	    NSDictionary *dic = (__bridge NSDictionary *)ref;
	    return [dic[@"width"] floatValue];
	}  
创建runDelegate
	
		CTRunDelegateCallbacks callback;
	    callback.version = kCTRunDelegateCurrentVersion;
	    callback.dealloc = deallocCallback;
	    callback.getWidth = getWidthCallback;
	    callback.getAscent = getAscentCallback;
	    callback.getDescent = getDecentCallback;
	    NSDictionary *ref = @{@"width":@100,
	                          @"ascent":@20,
	                          @"decent":@10,};
	    CTRunDelegateRef runDelegate = CTRunDelegateCreate(&callback, (__bridge_retained void *)ref);
	    
创建CTRunDelegate之后需要通过给NSAttributedString添加Attribute绑定  

	[attrStr addAttribute:(id)kCTRunDelegateAttributeName
	                value:(__bridge id)runDelegate
	                range:NSMakeRange(0, 1)];
通过上面可以根据图片的信息预先为图片留出相应的位置，在渲染的时候将图片渲染到图层上面。
	                