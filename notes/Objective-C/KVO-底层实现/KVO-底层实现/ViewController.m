//
//  ViewController.m
//  KVO-底层实现
//
//  Created by leeyii on 2017/9/13.
//  Copyright © 2017年 leeyii. All rights reserved.
//

#import "ViewController.h"
#import "Person.h"
#import <objc/runtime.h>
#import "NSObject+KVO_Extension.h"

static int a;

@interface ClassA : NSObject

//@property (nonatomic , strong) ClassA next;

@end

@implementation ClassA

void tes() {
     NSLog(@"1");
}

static int c;

- (void) method1 {
    c = 2;
    a = 2;
    
}

@end


@interface ViewController ()

@end

@implementation ViewController

static int b;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    a = 1;
    b = 2;
    c = 3;
    Person *p = [Person new];
    Person *son = [Person new];
    p.son = son;
    tes();
    
    [p kvo_addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:nil];
    
    
    p.name = @"10";
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

