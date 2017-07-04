//
//  NSObject+SMKVOBlock.h
//  KVOTest
//
//  Created by xiwang wang on 2017/7/4.
//  Copyright © 2017年 xiwang wang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^SMKVOBlock)(id observedObj, NSString *observedKey, id oldValue, id newValue);

@interface NSObject (SMKVOBlock)

- (void)sm_addObserver:(NSObject *)observer forKey:(NSString *)key block:(SMKVOBlock)block;

- (void)rm_observer:(NSObject *)observer forKeyPath:(NSString *)keyPath;

@end

