//
//  Person.m
//  KVO-底层实现
//
//  Created by leeyii on 2017/9/13.
//  Copyright © 2017年 leeyii. All rights reserved.
//

#import "Person.h"

@implementation Person

- (void)setName:(NSString *)name {
    [self willChangeValueForKey:@"name"];
    _name = name.copy;
    [self didChangeValueForKey:@"name"];
}

- (void)setAge:(int)age {
    _age = age;
}

@end
