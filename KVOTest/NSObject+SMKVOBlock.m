//
//  NSObject+SMKVOBlock.m
//  KVOTest
//
//  Created by xiwang wang on 2017/7/4.
//  Copyright © 2017年 xiwang wang. All rights reserved.
//

#import "NSObject+SMKVOBlock.h"
#import <objc/runtime.h>
#import <objc/message.h>

NSString *const SMKVOClassPrefix = @"SMKVONotifying_";
const char * SMKVOAssociateKey;

@interface SMObserverInfo : NSObject

@property (weak, nonatomic) NSObject *observer;
@property (copy, nonatomic) NSString *key;
@property (copy, nonatomic) SMKVOBlock block;

- (instancetype)initWithObserver:(NSObject *)observer Key:(NSString *)key block:(SMKVOBlock)block;

@end

@implementation NSObject (SMKVOBlock)

- (void)sm_addObserver:(NSObject *)observer forKey:(NSString *)key block:(SMKVOBlock)block {
    NSString *setter = [self setterFromKey:key];
    
    SEL setterS = NSSelectorFromString(setter);
    Method setterM = class_getInstanceMethod([self class], setterS);
    if (!setterM) {
        NSString * reason = [NSString stringWithFormat:@"找不到%@对应属性%@的setter", self, key];
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:nil];
        return;
    }
    
    Class newCls = [self kvoObervedClassFromOriginClass:[self class]];
    object_setClass(self, newCls);
    
    //rewrite setter
    const char * types = method_getTypeEncoding(setterM);
    class_addMethod(newCls, setterS, (IMP)newSetter, types);
    
    SMObserverInfo *observerInfo = [[SMObserverInfo alloc] initWithObserver:observer Key:key block:block];
    [self addObserver:observerInfo];
}

- (void)rm_observer:(NSObject *)observer forKeyPath:(NSString *)keyPath {
    NSMutableArray *observers = objc_getAssociatedObject(self, SMKVOAssociateKey);
    for (SMObserverInfo *observerInfo in observers) {
        if (observer == observerInfo && [observerInfo.key isEqualToString:keyPath]) {
            [observers removeObject:observerInfo];
            break;
        }
    }
}

- (void)addObserver:(NSObject *)observer {
    NSMutableArray *obervers = objc_getAssociatedObject(self, SMKVOAssociateKey);
    if (!obervers) {
        obervers = [NSMutableArray array];
        objc_setAssociatedObject(self, SMKVOAssociateKey, obervers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    [obervers addObject:observer];
}

void newSetter(id self,SEL _cmd, id newValue) {
    NSString *setter = NSStringFromSelector(_cmd);
    NSString *getter = [self getterFromSetter:setter];
    if (!getter) {
        NSString *reason = [NSString stringWithFormat:@"找不到%@对应属性%@的setter", self, getter];
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:nil];
        return;
    }
    
    NSString *key = [[getter componentsSeparatedByString:@":"] firstObject];
    id oldValue = [self valueForKey:key];
    
    if (oldValue == newValue) {
        return;
    }
    
    struct objc_super supercls = {
        .receiver = self,
        .super_class = class_getSuperclass(object_getClass(self))
    };
    void (*objc_msgSendSuperCasted)(void *, SEL, id) = (void *)objc_msgSendSuper;
    objc_msgSendSuperCasted(&supercls, _cmd, newValue);
//    objc_msgSendSuper(&supercls, _cmd, newValue);
    NSMutableArray *observers = objc_getAssociatedObject(self, SMKVOAssociateKey);
    for (SMObserverInfo *obs in observers) {
        if ([obs.key isEqualToString:key]) {
            obs.block(self, key, oldValue, newValue);
        }
    }
    
}

- (NSString *)getterFromSetter:(NSString *)setter{
    NSString *getter = [setter substringFromIndex:3];
    NSString *firstLow = [[getter substringToIndex:1] lowercaseString];
    return [getter stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:firstLow];
}

- (Class)kvoObervedClassFromOriginClass:(Class)cls{
    
    NSString *clsStr = NSStringFromClass(cls);
    NSString *newClsStr = [SMKVOClassPrefix stringByAppendingString:clsStr];
    Class newCls = NSClassFromString(newClsStr);
    if (newCls) {
        return newCls;
    }
    
    // class doesn't exist yet, make it
    Class originalClazz = object_getClass(self);
    newCls = objc_allocateClassPair(originalClazz, newClsStr.UTF8String, 0);
    
    // grab class method's signature so we can borrow it
//    Method clazzMethod = class_getInstanceMethod(originalClazz, @selector(class));
//    const char *types = method_getTypeEncoding(clazzMethod);
//    class_addMethod(newCls, @selector(class), (IMP)kvo_class, types);
    
    [self rewriteClassMethodWithNewClass:newCls];
    objc_registerClassPair(newCls);
    return newCls;
}

- (void)rewriteClassMethodWithNewClass:(Class)newCls {
    Method clsMethod = class_getInstanceMethod([self class], @selector(class));
    const char * types = method_getTypeEncoding(clsMethod);
    class_addMethod(newCls, @selector(class), (IMP)newClass, types);
}

Class newClass(id self, SEL _cmd) {
    return class_getSuperclass(object_getClass(self));
}

//Class kvo_class(id self, SEL _cmd)
//{
//    return class_getSuperclass(object_getClass(self));
//}

- (NSString *)setterFromKey:(NSString *)key {
    NSMutableString *mutbleStr = [NSMutableString stringWithString:key];
    [mutbleStr replaceCharactersInRange:NSMakeRange(0, 1) withString:[[key substringToIndex:1] uppercaseString]];
    return [NSString stringWithFormat:@"set%@:",mutbleStr];
}

@end


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
