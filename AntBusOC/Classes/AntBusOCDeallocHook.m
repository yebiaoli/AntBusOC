#import "AntBusOCDeallocHook.h"
#import <objc/runtime.h>

@interface AntBusOCDeallocHookHook : NSObject
@property (nonatomic,copy) NSString * propertyKey;
@property (nonatomic,strong) NSMutableSet<NSString *> * handlerKeys;
@property (nonatomic,copy) AntBusOCDeallocHookHandler handler;
@property (nonatomic,copy) NSString * type;
@end

@implementation AntBusOCDeallocHookHook

- (void)dealloc{
    NSLog(@"--- dealloc AntBusOCDeallocHookHook ---\n.type:%@ \n.propertyKey:%@ \n.handlerKeys:%@",self.type,self.propertyKey,self.handlerKeys);
    if(self.handler){
        self.handler(self.handlerKeys);
    }
}

- (NSMutableSet<NSString *> *)handlerKeys{
    if(!_handlerKeys){
        _handlerKeys = [NSMutableSet new];
    }
    return _handlerKeys;
}

- (void)addHandlerKey:(NSString *)handlerKey{
    [self.handlerKeys addObject:handlerKey];
}
- (void)removeHandlerKey:(NSString *)handlerKey{
    [self.handlerKeys removeObject:handlerKey];
}
@end


@implementation AntBusOCDeallocHook

+ (AntBusOCDeallocHook *)shared{
    static AntBusOCDeallocHook * instance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [AntBusOCDeallocHook new];
    });
    return instance;
}

- (void)installDeallocHookForObject:(id)obj
                        propertyKey:(NSString *)propertyKey
                          handleKey:(NSString *)handleKey
                            handler:(AntBusOCDeallocHookHandler)handler{
    if(!obj || !propertyKey || !handleKey){
        return;
    }
    AntBusOCDeallocHookHook * hook = objc_getAssociatedObject(obj, (__bridge const void * _Nonnull)(propertyKey));
    if(hook){
        [hook addHandlerKey:handleKey];
        return ;
    }
    hook = [[AntBusOCDeallocHookHook alloc] init];
    hook.propertyKey = propertyKey;
    hook.handler = handler;
    hook.type = NSStringFromClass([obj class]);
    [hook addHandlerKey:handleKey];
    objc_setAssociatedObject(obj, (__bridge const void * _Nonnull)(propertyKey), hook, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)uninstallDeallocHookForObject:(id)obj
                          propertyKey:(NSString *)propertyKey{
    if(!obj || !propertyKey){
        return;
    }
    objc_setAssociatedObject(obj, (__bridge const void * _Nonnull)(propertyKey), nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)uninstallDeallocHookForObject:(id)obj
                          propertyKey:(NSString *)propertyKey
                            handleKey:(NSString *)handleKey{
    if(!obj || !propertyKey || !handleKey){
        return;
    }
    AntBusOCDeallocHookHook * hook = objc_getAssociatedObject(obj, (__bridge const void * _Nonnull)(propertyKey));
    [hook removeHandlerKey:handleKey];
}

@end
