//
//  NSObject+KVO_Extension.h
//  KVO-底层实现
//
//  Created by leeyii on 2017/9/18.
//  Copyright © 2017年 leeyii. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (KVO_Extension)

- (void)kvo_addObserver:(nonnull id)observer
             forKeyPath:(NSString *)keyPath
                options:(NSKeyValueObservingOptions)options
                context:(nullable void *)context;
- (void)kvo_removeObserver:(nonnull id)observer forKeyPath:(NSString *)keyPath;

- (void)kvo_removeObserver:(nonnull id)observer;

@end

NS_ASSUME_NONNULL_END
