//
//  ViewController.m
//  KVOTest
//
//  Created by xiwang wang on 2017/7/4.
//  Copyright © 2017年 xiwang wang. All rights reserved.
//

#import "ViewController.h"
#import "Person.h"
#import "NSObject+SMKVOBlock.h"
@interface ViewController ()
@end

@implementation ViewController
{
    Person *_p;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _p = [Person new];
    [_p sm_addObserver:self forKey:@"name" block:^(id observedObj, NSString *observedKey, id oldValue, id newValue) {
        NSLog(@"---------------");
        NSLog(@"%@\n%@\n%@\n%@\n",observedObj,observedKey,oldValue,newValue);
    }];
    
    NSLog(@"-----%@",[_p class]);
    _p.name = @"simon";
    [_p setValue:@"simon22" forKey:@"name"];
    [_p rm_observer:self forKeyPath:@"name"];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    static NSInteger index = 0;
    _p.name = [NSString stringWithFormat:@"simon%ld",index];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
