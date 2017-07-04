//
//  SMObserverInfo.m
//  KVOTest
//
//  Created by xiwang wang on 2017/7/4.
//  Copyright © 2017年 xiwang wang. All rights reserved.
//

#import "SMObserverInfo.h"

@implementation SMObserverInfo

- (instancetype)initWithObserver:(NSObject *)observer Key:(NSString *)key block:(SMKVOBlock)block {
    if (self = [super init]) {
        _observer = observer;
        _key = key;
        _block = block;
    }
    return self;
}

@end
