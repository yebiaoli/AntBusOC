#import "AntBusOCChannel.h"
#import "AntBusOCDeallocHook.h"

//MARK: - Single
@interface AntBusOCChannelSingle: NSObject<IAntBusOCChannelSingle>
@property (nonatomic,strong) NSMapTable * container;
@end

@implementation AntBusOCChannelSingle : NSObject

- (NSMapTable *)container{
    if(!_container){
        _container = [NSMapTable strongToWeakObjectsMapTable];
    }
    return _container;
}

- (void)regDeallocHandler:(NSString *)hkey responder:(id)responder{
    __weak typeof(self) weakself = self;
    [AntBusOCDeallocHook.shared installDeallocHookForObject:responder propertyKey:@"AntBusOCChannelSingle" handleKey:hkey handler:^(NSSet<NSString *> * _Nonnull handlerKeys) {
        for(NSString * hkey in handlerKeys){
            if(![weakself.container objectForKey:hkey]){
                [weakself.container removeObjectForKey:hkey];
            }
        }
    }];
}

// -----------
- (void)registerWithInterface:(Protocol * _Nonnull)interface responder:(id _Nonnull)responder{
    NSString * type = NSStringFromProtocol(interface);
    if(![responder conformsToProtocol:interface]){
        NSAssert(NO, ([NSString stringWithFormat:@"error: responder(%@) does not implement protocol %@.",responder,type]));
        return;
    }
    [self.container setObject:responder forKey:type];
    [self regDeallocHandler:type responder:responder];
}

- (void)registerWithClazz:(Class _Nonnull)clazz responder:(id _Nonnull)responder{
    if(![responder isKindOfClass:clazz]){
        NSAssert(NO, ([NSString stringWithFormat:@"error: responder(%@) is not a subclass of %@.",responder,clazz]));
        return;
    }
    
    NSString * type = NSStringFromClass(clazz);
    [self.container setObject:responder forKey:type];
    [self regDeallocHandler:type responder:responder];
}

- (id _Nullable)responderWithInterface:(Protocol * _Nonnull)interface{
    NSString * type = NSStringFromProtocol(interface);
    return [self.container objectForKey:type];
}

- (id _Nullable)responderWithClazz:(Class _Nonnull)clazz{
    NSString * type = NSStringFromClass(clazz);
    return [self.container objectForKey:type];
}

- (void)removeWithInterface:(Protocol * _Nonnull)interface{
    NSString * type = NSStringFromProtocol(interface);
    [self.container removeObjectForKey:type];
}

- (void)removeWithClazz:(Class _Nonnull)clazz{
    NSString * type = NSStringFromClass(clazz);
    [self.container removeObjectForKey:type];
}

- (void)removeAll{
    [self.container removeAllObjects];
}

@end


//MARK: - Multi
@interface AntBusOCChannelMulti : NSObject<IAntBusOCChannelMulti>
@property (nonatomic,strong) NSMutableDictionary<NSString *, NSMutableDictionary<NSString *,NSHashTable *> *> * container;
@end

@implementation AntBusOCChannelMulti

- (NSMutableDictionary<NSString *,NSMutableDictionary<NSString *,NSHashTable *> *> *)container{
    if(!_container){
        _container = [NSMutableDictionary new];
    }
    return _container;
}

- (NSMutableDictionary<NSString *,NSHashTable *> *)getTypeContainer:(NSString *)type createIsExist:(BOOL)createIsExist {
    NSMutableDictionary<NSString *,NSHashTable *> * typeContainer = [self.container objectForKey:type];
    if(!typeContainer && createIsExist){
        typeContainer = [NSMutableDictionary new];
        [self.container setObject:typeContainer forKey:type];
    }
    return typeContainer;
}

- (NSHashTable *)getKeyContainerWithTypeContainer:(NSMutableDictionary<NSString *,NSHashTable *> *)typeContainer key:(NSString *)key createIsExist:(BOOL)createIsExist {
    if(!typeContainer){
        return nil;
    }
    NSHashTable * keyContainer = [typeContainer objectForKey:key];
    if(!keyContainer && createIsExist){
        keyContainer = [NSHashTable weakObjectsHashTable];
        [typeContainer setObject:keyContainer forKey:key];
    }
    return keyContainer;
}

- (void)regDeallocHandlerWithType:(NSString *)type keyContainer:(NSHashTable *)keyContainer key:(NSString *)key responder:(id)responder{
    
    __weak typeof(self) weakself = self;
    
    [AntBusOCDeallocHook.shared installDeallocHookForObject:responder propertyKey:@"AntBusOCChannelMulti" handleKey:key handler:^(NSSet<NSString *> * _Nonnull handlerKeys) {
        NSMutableDictionary<NSString *,NSHashTable *> * typeContainer = [weakself getTypeContainer:type createIsExist:NO];
        for(NSString * hkey in handlerKeys){
            if(typeContainer){
                NSHashTable * keyContainer = [weakself getKeyContainerWithTypeContainer:typeContainer key:hkey createIsExist:NO];
                if(keyContainer && keyContainer.allObjects.count == 0){
                    [typeContainer removeObjectForKey:type];
                }
            }else{
                [typeContainer removeObjectForKey:type];
            }
        }
        if(typeContainer.allValues.count == 0){
            [weakself.container removeObjectForKey:type];
        }
    }];
}

- (void)registerWithInterface:(Protocol * _Nonnull)interface key:(NSString * _Nonnull)key responder:(id _Nonnull)responder{
    NSString * type = NSStringFromProtocol(interface);
    if(![responder conformsToProtocol:interface]){
        NSAssert(NO, ([NSString stringWithFormat:@"error: responder(%@) does not implement protocol %@.",responder,type]));
        return;
    }
    NSMutableDictionary<NSString *,NSHashTable *> * typeContainer = [self getTypeContainer:type createIsExist:YES];
    NSHashTable * keyContainer = [self getKeyContainerWithTypeContainer:typeContainer key:key createIsExist:YES];
    [keyContainer addObject:responder];
    [self regDeallocHandlerWithType:type keyContainer:keyContainer key:key responder:responder];
}

- (void)registerWithClazz:(Class _Nonnull)clazz key:(NSString * _Nonnull)key responder:(id _Nonnull)responder{
    if(![responder isKindOfClass:clazz]){
        NSAssert(NO, ([NSString stringWithFormat:@"error: responder(%@) is not a subclass of %@.",responder,clazz]));
        return;
    }
    NSString * type = NSStringFromClass(clazz);
    NSMutableDictionary<NSString *,NSHashTable *> * typeContainer = [self getTypeContainer:type createIsExist:YES];
    NSHashTable * keyContainer = [self getKeyContainerWithTypeContainer:typeContainer key:key createIsExist:YES];
    [keyContainer addObject:responder];
    [self regDeallocHandlerWithType:type keyContainer:keyContainer key:key responder:responder];
}

- (NSArray * _Nullable)responderWithInterface:(Protocol * _Nonnull)interface key:(NSString * _Nonnull)key{
    NSString * type = NSStringFromProtocol(interface);
    NSMutableDictionary<NSString *,NSHashTable *> * typeContainer = [self getTypeContainer:type createIsExist:NO];
    if(typeContainer){
        NSHashTable * keyContainer = [self getKeyContainerWithTypeContainer:typeContainer key:key createIsExist:NO];
        if(keyContainer){
            return keyContainer.allObjects;
        }
    }
    return nil;
}

- (NSArray * _Nullable)responderWithClazz:(Class _Nonnull)clazz key:(NSString * _Nonnull)key{
    NSString * type = NSStringFromClass(clazz);
    NSMutableDictionary<NSString *,NSHashTable *> * typeContainer = [self getTypeContainer:type createIsExist:NO];
    if(typeContainer){
        NSHashTable * keyContainer = [self getKeyContainerWithTypeContainer:typeContainer key:key createIsExist:NO];
        if(keyContainer){
            return keyContainer.allObjects;
        }
    }
    return nil;
}

- (NSArray * _Nullable)responderWithInterface:(Protocol * _Nonnull)interface{
    NSString * type = NSStringFromProtocol(interface);
    NSMutableDictionary<NSString *,NSHashTable *> * typeContainer = [self getTypeContainer:type createIsExist:NO];
    
    NSMutableSet * rs = [NSMutableSet new];
    for(NSHashTable * table in typeContainer.allValues){
        [rs addObjectsFromArray:table.allObjects];
    }
    return rs.allObjects;
}

- (NSArray * _Nullable)responderWithClazz:(Class _Nonnull)clazz{
    NSString * type = NSStringFromClass(clazz);
    NSMutableDictionary<NSString *,NSHashTable *> * typeContainer = [self getTypeContainer:type createIsExist:NO];
    
    NSMutableSet * rs = [NSMutableSet new];
    for(NSHashTable * table in typeContainer.allValues){
        [rs addObjectsFromArray:table.allObjects];
    }
    return rs.allObjects;
}

- (void)removeWithInterface:(Protocol * _Nonnull)interface key:(NSString * _Nonnull)key responder:(id _Nonnull)responder{
    NSString * type = NSStringFromProtocol(interface);
    NSMutableDictionary<NSString *,NSHashTable *> * typeContainer = [self getTypeContainer:type createIsExist:NO];
    NSHashTable * keyContainer = [self getKeyContainerWithTypeContainer:typeContainer key:key createIsExist:NO];
    if(keyContainer){
        [keyContainer removeObject:responder];
    }
}

- (void)removeWithClazz:(Class _Nonnull)clazz key:(NSString * _Nonnull)key responder:(id _Nonnull)responder{
    NSString * type = NSStringFromClass(clazz);
    NSMutableDictionary<NSString *,NSHashTable *> * typeContainer = [self getTypeContainer:type createIsExist:NO];
    NSHashTable * keyContainer = [self getKeyContainerWithTypeContainer:typeContainer key:key createIsExist:NO];
    if(keyContainer){
        [keyContainer removeObject:responder];
    }
}

- (void)removeWithInterface:(Protocol * _Nonnull)interface key:(NSString * _Nonnull)key{
    NSString * type = NSStringFromProtocol(interface);
    NSMutableDictionary<NSString *,NSHashTable *> * typeContainer = [self getTypeContainer:type createIsExist:NO];
    [typeContainer removeObjectForKey:key];
}

- (void)removeWithClazz:(Class _Nonnull)clazz key:(NSString * _Nonnull)key{
    NSString * type = NSStringFromClass(clazz);
    NSMutableDictionary<NSString *,NSHashTable *> * typeContainer = [self getTypeContainer:type createIsExist:NO];
    [typeContainer removeObjectForKey:key];
}

- (void)removeWithInterface:(Protocol * _Nonnull)interface{
    NSString * type = NSStringFromProtocol(interface);
    [self.container removeObjectForKey:type];
}

- (void)removeWithClazz:(Class _Nonnull)clazz{
    NSString * type = NSStringFromClass(clazz);
    [self.container removeObjectForKey:type];
}

- (void)removeAll{
    [self.container removeAllObjects];
}

@end


@implementation AntBusOCChannel

+ (id<IAntBusOCChannelSingle>)single{
    static AntBusOCChannelSingle * instance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [AntBusOCChannelSingle new];
    });
    return instance;
}

+ (id<IAntBusOCChannelMulti>)multi{
    static AntBusOCChannelMulti * instance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [AntBusOCChannelMulti new];
    });
    return instance;
}

- (id<IAntBusOCChannelSingle>)single{
    return AntBusOCChannel.single;
}

- (id<IAntBusOCChannelMulti>)multi{
    return AntBusOCChannel.multi;
}

@end
