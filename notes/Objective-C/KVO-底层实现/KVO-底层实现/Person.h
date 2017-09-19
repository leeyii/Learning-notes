//
//  Person.h
//  KVO-底层实现
//
//  Created by leeyii on 2017/9/13.
//  Copyright © 2017年 leeyii. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Person : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) int age;
@property (nonatomic, strong) Person *son;

@end
