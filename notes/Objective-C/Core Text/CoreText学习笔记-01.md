#Core Text 学习笔记

##  Glyphs（字形）
* 字符的图形形式， 则是文字中字母 (character) 的视觉表现。
* （字形）Glyphs = 字符（Character）+ 字体（font）字符通过字体（map）找到字形
* OC中的表现形式: 字形 CGGlyph  字体 UIFont/CTFont 字符 unichar  
![](http://upload-images.jianshu.io/upload_images/681146-8c7d887f58f904b1.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

* 字形描述集(Glyphs Metris):即字形的各个参数。如下面的两张图:![](http://xiangwangfeng.com/images/ct2.jpg)   
* ![](http://xiangwangfeng.com/images/ct3.jpg)  
	边框(Bounding Box)：一个假想的边框，尽可能地容纳整个字形。  
	基线(Baseline)：一条假想的参照线，以此为基础进行字形的渲染。一般来说是一条横线。  
基础原点(Origin)：基线上最左侧的点。  
行间距(Leading)：行与行之间的间距。  
字间距(Kerning)：字与字之间的距离，为了排版的美观，并不是所有的字形之间的距离都是一致的，但是这个基本步影响到我们的文字排版。  
上行高度(Ascent)和下行高度(Decent)：一个字形最高点和最低点到基线的距离，前者为正数，而后者为负数。当同一行内有不同字体的文字时，就取最大值作为相应的值。如下图，  
![](http://xiangwangfeng.com/images/ct4.jpg)   
红框高度既为当前行的行高，绿线为baseline，绿色到红框上部分为当前行的最大Ascent，绿线到黄线为当前行的最大Desent，而黄框的高即为行间距。由此可以得出：lineHeight = Ascent + |Decent| + Leading。 更加详细的内容可以参考苹果的这篇文档： [《Cocoa Text Architecture Guide》](https://developer.apple.com/library/mac/documentation/TextFonts/Conceptual/CocoaTextArchitecture/Introduction/Introduction.html#//apple_ref/doc/uid/TP40009459-CH1-SW1)  。当然如果要做到更完善的排版，还需要掌握段落排版(Paragragh Style)相关的知识，但是如果只是完成聊天框内的文字排版，以上的基础知识已经够用了。详细的段落样式相关知识可以参考： [《Ruler and Paragraph Style Programming Topics》](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/Rulers/Rulers.html#//apple_ref/doc/uid/10000089i)




##  Core Text简介
CoreText 是用于处理文字和字体的底层技术。它直接和 Core Graphics（又被称为 Quartz）打交道。Quartz 是一个 2D 图形渲染引擎，能够处理 OSX 和 iOS 中的图形显示。

>注意：这个是 iOS7 之后的架构图，在 iOS7 以前，并没有图中的 Text Kit 类，不过 CoreText 仍然是处在最底层直接和 Core Graphics 打交道的模块。

![](http://tangqiao.b0.upaiyun.com/coretext/coretext_arch.png)    
图上可以看出CoreText处于非常底层的位置上层的UILabel，UITextfield等都是通过CoreText来实现的。
Quartz 这个框架能够直接通过字形（glyphs）和位置（positions）将文字渲染在视图上面。  

**UIWebView 也是处理复杂的文字排版的备选方案。对于排版，基于 CoreText 和基于 UIWebView 相比，前者有以下好处：** 
  
* CoreText 占用的内存更少，渲染速度快，UIWebView 占用的内存更多，渲染速度慢。  
*  CoreText 在渲染界面前就可以精确地获得显示内容的高度（只要有了 CTFrame 即可），而 UIWebView 只有渲染出内容后，才能获得内容的高度（而且还需要用 javascript 代码来获取）  
* CoreText 的 CTFrame 可以在后台线程渲染，UIWebView 的内容只能在主线程（UI 线程）渲染。  
基于 CoreText 可以做更好的原生交互效果，交互效果可以更细腻。而 UIWebView 的交互效果都是用 javascript 来实现的，在交互效果上会有一些卡顿存在。例如，在 UIWebView 下，一个简单的按钮按下效果，都无法做到原生按钮的即时和细腻的按下效果。  

**当然，基于 CoreText 的排版方案也有一些劣势：** 

* CoreText 渲染出来的内容不能像 UIWebView 那样方便地支持内容的复制。  
* 基于 CoreText 来排版需要自己处理很多复杂逻辑，例如需要自己处理图片与文字混排相关的逻辑，也需要自己实现链接点击操作的支持。

##  Core Text关键类

###NSAttributedString
富文本，使用NSAttributedString（CFAttributedStringRef）可以创建CTFramesetter。  
`- (instancetype)initWithString:(NSString *)str attributes:(nullable NSDictionary<NSString *, id> *)attrs`
第二个参数attributes：包含了详细的文字排版信息。详细的信息可以在`<CoreText/CTStringAttributes.h>`或者`#<Foundation/NSAttributedString.h>`文件中看到。

![](https://developer.apple.com/library/content/documentation/StringsTextFonts/Conceptual/CoreText_Programming/Art/core_text_arch_2x.png)

###CTFramesetter
通过CFAttributedString(NSAttributedString)创建，作用相当于一个生产CTFrame的工厂。   
 
###CTFrame   
每个CTFrame可以看做一个段落 每个CTFrame由多个CTLine组成。可以使用它进行绘制  

###CTLine  
代表一个line 一行文字中可能有多个CTLine组成，单每一个CTLine一定在同一行内。 一个CTLine有多个CTRun组成。也可以使用它进行绘制。  

###CTRun  
一个连续的有着相同的attributes和direction的字形（glyph）的集合，是最小的字形绘制单元。  

###CTTypesetter  
通过CFAttributedString(NSAttributedString)创建，相当于一个生产CTLine的工厂。  

![e](http://tangqiao.b0.upaiyun.com/coretext/coretext-ctline.jpg)


##代码

自定义一个view继承UIView，重写drawRect: 方法  
使用Core Text简单的绘制一个段落

	- (void)drawRect:(CGRect)rect {
	    // Drawing code
	    
	    // 1.获取绘制上下文
	    CGContextRef context = UIGraphicsGetCurrentContext();
	    
	    // 2.翻转坐标系
	    //	  对于底层绘制引擎来说左下角是（0，0），对于上层UIKit来说左上是（0，0）点
	    CGContextTranslateCTM(context, 0, self.bounds.size.height);
	    CGContextScaleCTM(context, 1.0, -1.0);
	    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
	    
	    // 3.创建矩形的路径 指定文字的绘制范围
	    CGMutablePathRef path = CGPathCreateMutable();
	    CGPathAddRect(path, NULL, self.bounds);
	    
	   	// 4.创建富文本
	    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:@"Hello, World! I know nothing in the world that has as much power as a word. Sometimes I write one, and I look at it, until it begins to shine." attributes:nil];
	    
	    // 5.根据attrStr初始化CTFramesetterRef
	    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(attrStr);
	    
	    // 6.使用framesetter根据刚才创建的绘制路径和字符串范围初始化CTFrameRef
	    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
	    // 7.在指定的上下文中绘制指定的内容
	    CTFrameDraw(frame, context);
	    
	    // 8. 释放内存
	    CFRelease(frame);
	    CFRelease(framesetter);
	    CFRelease(path);
	
	}

***
Reference:
>[Core Text Programming Guide](https://developer.apple.com/library/content/documentation/StringsTextFonts/Conceptual/CoreText_Programming/Introduction/Introduction.html#//apple_ref/doc/uid/TP40005533-CH1-SW1)  
>[iOS文字排版(CoreText)那些事](http://xiangwangfeng.com/2014/03/06/iOS%E6%96%87%E5%AD%97%E6%8E%92%E7%89%88%28CoreText%29%E9%82%A3%E4%BA%9B%E4%BA%8B/)  
>[基于 CoreText 的排版引擎：基础](http://blog.devtang.com/2015/06/27/using-coretext-1/)  
>[CoreText入门](CoreText入门)

