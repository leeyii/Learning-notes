//
//  NSObject+KVO_Extension.m
//  KVO-底层实现
//
//  Created by leeyii on 2017/9/18.
//  Copyright © 2017年 leeyii. All rights reserved.
//

#import "NSObject+KVO_Extension.h"
#import <objc/message.h>

static NSString *const kNSKVONotifyingPrefix = @"NSKVONotifying_";
static const char kObserversAssociatesKey;

@interface _ObserverInfo : NSObject

@property (nonatomic, weak) id observer;
@property (nonatomic, copy) NSString *key;
@property (nonatomic, assign) NSKeyValueObservingOptions options;
@property (nonatomic, assign) void *context;

@end

@implementation _ObserverInfo

- (instancetype)initWithObserver:(id)observer
                             key:(NSString *)key
                         options:(NSKeyValueObservingOptions)options
                         context:(void *)context {
    if (self = [super init]) {
        self.observer = observer;
        self.key = key;
        self.options = options;
        self.context = context;
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if (object == self) return YES;
    if (![object isKindOfClass:[self class]]) return NO;
    _ObserverInfo *obj = object;
    if (obj.observer != self.observer)  return NO;
    if (obj.key != self.key)            return NO;
    if (obj.context != self.context)    return NO;
    return YES;
}


@end


@implementation NSObject (KVO_Extension)

#pragma mark - helper
static NSString * setterForGetter(NSString * key) {
    if (key.length == 0 ||
        [key hasSuffix:@":"]) return nil;
    NSMutableString *str = key.mutableCopy;
    [str replaceCharactersInRange:NSMakeRange(0, 1)
                       withString:[[str substringToIndex:1] uppercaseString]];
    [str insertString:@"set" atIndex:0];
    [str appendString:@":"];
    return str.copy;
}

static NSString * getterForSetter(NSString * key) {
    if (key.length == 0 ||
        ![key hasPrefix:@"set"] ||
        ![key hasSuffix:@":"]) return nil;
    NSMutableString *str = key.mutableCopy;
    [str deleteCharactersInRange:NSMakeRange(0, 3)];
    [str replaceCharactersInRange:NSMakeRange(0, 1) withString:[[str substringToIndex:1] lowercaseString]];
    [str deleteCharactersInRange:NSMakeRange(str.length - 1, 1)];
    return str.copy;
}

#pragma mark - Method C imp
// setter
static void kvo_setter (id self, SEL _cmd, id newValue) {
    NSString *setterName = [NSString stringWithUTF8String:sel_getName(_cmd)];
    NSString *getterName = getterForSetter(setterName);
    id oldValue = [self valueForKey:getterName];
    
    // 调用super set方法 [super setXXX]
    struct objc_super supCls = {};
    supCls.receiver = self;
    supCls.super_class = class_getSuperclass(object_getClass(self));
    void (*objc_msgSendSuperP)(void *, SEL, id) = (void *)objc_msgSendSuper;
    objc_msgSendSuperP(&supCls, _cmd, newValue);
    
    NSMutableDictionary *observers = [self allObserversDic];
    NSMutableArray *arr = observers[getterName];
    if (!arr) return;
    
    for (_ObserverInfo *info in arr) {
        NSMutableDictionary *change = @{}.mutableCopy;
        if (info.options & NSKeyValueObservingOptionOld) {
            change[NSKeyValueChangeOldKey] = oldValue;
        }
        if (info.options & NSKeyValueObservingOptionNew) {
            change[NSKeyValueChangeNewKey] = newValue;
        }
        [info.observer observeValueForKeyPath:info.key
                                     ofObject:self
                                       change:change.copy
                                      context:info.context];
        
    }
}

// class
static Class kvo_class(id self, SEL _cmd) {
    return class_getSuperclass(object_getClass(self));
}


- (void)kvo_addObserver:(id)observer
             forKeyPath:(NSString *)keyPath
                options:(NSKeyValueObservingOptions)options
                context:(void *)context {
    // 1. 参数判断
    if (!observer || keyPath.length == 0)  return;
    
    // 2. 添加派生类
    
    NSString *clsName = NSStringFromClass([self class]);
    
    if (![clsName hasPrefix:kNSKVONotifyingPrefix]) {
        Class newCls = [self createPairClass];
        object_setClass(self, newCls);
    }
    
    // 3. 添加setter
    if (![self hasSelector:NSSelectorFromString(setterForGetter(keyPath))]) {
        Method m = class_getInstanceMethod([self class], NSSelectorFromString(setterForGetter(keyPath)));
        const char *typs = method_getTypeEncoding(m);
        class_addMethod(object_getClass(self), NSSelectorFromString(setterForGetter(keyPath)), (IMP)kvo_setter, typs);
    }
    
    NSMutableDictionary *observers = [self allObserversDic];
    NSMutableArray *arr = observers[keyPath];
    if (!arr) {
        arr = @[].mutableCopy;
        observers[keyPath] = arr;
    }

    _ObserverInfo *info = [[_ObserverInfo alloc] initWithObserver:observer key:keyPath options:options context:context];
    [arr addObject:info];
}

- (void)kvo_removeObserver:(id)observer forKeyPath:(NSString *)keyPath {
    NSMutableDictionary *observers = [self allObserversDic];
    NSMutableArray *arr = observers[keyPath];
    if (!arr) return;
    [arr enumerateObjectsUsingBlock:^(_ObserverInfo * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.observer == observer) {
            [arr removeObject:obj];
            return;
        }
    }];
}

- (void)kvo_removeObserver:(id)observer {
    NSMutableDictionary *observers = [self allObserversDic];
    
}

- (Class)createPairClass {
    NSString *clsName = [kNSKVONotifyingPrefix stringByAppendingString:NSStringFromClass([self class])];
    Class cls = NSClassFromString(clsName);
    if (!cls) {
        // 创建派生类
        cls = objc_allocateClassPair(object_getClass(self), clsName.UTF8String, 0);
        // 添加class方法
        Method m = class_getInstanceMethod(cls, @selector(class));
        const char *types = method_getTypeEncoding(m);
        class_addMethod(cls, @selector(class), (IMP)kvo_class, types);
        // 注册派生类
        objc_registerClassPair(cls);
    }
    return cls;
}

- (BOOL)hasSelector:(SEL)selector {
    
    Class cls = object_getClass(self);
    unsigned int count;
    Method *methods = class_copyMethodList(cls, &count);
    for (unsigned int i = 0; i < count; i++) {
        Method m = methods[i];
        SEL sel = method_getName(m);
        if (sel == selector) {
            free(methods);
            return YES;
        }
    }
    return NO;
}


- (NSMutableDictionary *)allObserversDic {
    NSMutableDictionary *observers = objc_getAssociatedObject(self, &kObserversAssociatesKey);
    if (!observers) {
        observers = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, &kObserversAssociatesKey, observers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return observers;
}

@end
