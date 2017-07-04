//
//  SMObserverInfo.h
//  KVOTest
//
//  Created by xiwang wang on 2017/7/4.
//  Copyright © 2017年 xiwang wang. All rights reserved.
//

#import "NSObject+SMKVOBlock.h"
#import <objc/runtime.h>

NSString *const SMKVOClassPrefix = @"SMKVONotifying_";
const char * SMKVOAssociateKey;

@interface SMObserverInfo : NSObject

@property (weak, nonatomic) NSObject *observer;
@property (copy, nonatomic) NSString *key;
@property (copy, nonatomic) SMKVOBlock block;

- (instancetype)initWithObserver:(NSObject *)observer Key:(NSString *)key block:(SMKVOBlock)block;

@end
