//
//  AntBusOC.m
//  AntBusOC
//
//  Created by liyebiao on 2021/2/5.
//

#import "AntBusOC.h"
#import "AntBusOC_WKMapTable.h"

@interface AntBusOCNotiChannel()
@property (nonatomic,strong) NSMapTable * koMap;
@property (nonatomic,strong) AntBusOC_WKMapTable * ohMap;
@end

@implementation AntBusOCNotiChannel

- (instancetype)init{
    self = [super init];
    if (self) {
        self.koMap = [NSMapTable strongToStrongObjectsMapTable];
        self.ohMap = [[AntBusOC_WKMapTable alloc] init];
    }
    return self;
}

- (void)registerKey:(NSString *)key owner:(id)owner handler:(AntBusOCResponseBlock)handler{
    if(!key || !owner || !handler){
        if(!key){NSLog(@"AntBusOCNotiChannel registerKey error: key is nil.. ");}
        if(!owner){NSLog(@"AntBusOCNotiChannel registerKey error: owner is nil.. ");}
        if(!handler){NSLog(@"AntBusOCNotiChannel registerKey error: handler is nil.. ");}
        return;
    }
    NSHashTable * oTable = [self.koMap objectForKey:key];
    if(!oTable){
        oTable = [NSHashTable weakObjectsHashTable];
        [self.koMap setObject:oTable forKey:key];
    }
    if(![oTable containsObject:owner]){
        [oTable addObject:owner];
    }
    
    NSMapTable * hMap = [self.ohMap objectForKey:owner];
    if(!hMap){
        hMap = [NSMapTable strongToStrongObjectsMapTable];
    }
    __weak typeof(self) weakself = self;
    [self.ohMap setObject:hMap forKey:owner hkey:key keyDeallocHandler:^(NSSet<NSString *> * _Nonnull hkeys) {
        for(NSString * hkey in hkeys){
            NSHashTable * oTable = [weakself.koMap objectForKey:hkey];
            if(oTable.allObjects.count == 0){
                [weakself.koMap removeObjectForKey:hkey];
            }
        }
    }];
    [hMap setObject:[handler copy] forKey:key];
}
- (void)callKey:(NSString *)key data:(id)data{
    if(!key){
        NSLog(@"AntBusOCNotiChannel callKey error: key is nil.. ");
        return;
    }
    NSHashTable * oTable = [self.koMap objectForKey:key];
    for(id owner in oTable.allObjects){
        NSMapTable * hMap = [self.ohMap objectForKey:owner];
        if(hMap){
            AntBusOCResponseBlock handler = [hMap objectForKey:key];
            if(handler){
                handler(data);
            }
        }
    }
}
- (void)removeKey:(NSString *)key owner:(id)owner{
    if(!key || !owner){
        if(!key){NSLog(@"AntBusOCNotiChannel removeKey error: key is nil.. ");}
        if(!owner){NSLog(@"AntBusOCNotiChannel removeKey error: owner is nil.. ");}
        return;
    }
    NSHashTable * oTable = [self.koMap objectForKey:key];
    if(oTable && [oTable containsObject:owner]){
        [oTable removeObject:owner];
    }
    NSMapTable * hMap = [self.ohMap objectForKey:owner];
    if(hMap){
        [hMap removeObjectForKey:key];
    }
}
- (void)removeKey:(NSString *)key{
    if(!key){
        if(!key){NSLog(@"AntBusOCNotiChannel removeKey error: key is nil.. ");}
        return;
    }
    NSHashTable * oTable = [self.koMap objectForKey:key];
    for(id owner in oTable.allObjects){
        NSMapTable * hMap = [self.ohMap objectForKey:owner];
        if(hMap){
            [hMap removeObjectForKey:key];
        }
    }
    [oTable removeAllObjects];
}
- (void)removeAll{
    [self.koMap removeAllObjects];
    [self.ohMap removeAllObjects];
}

@end





@interface AntBusOCDataChannel()
@property (nonatomic,strong) NSMapTable<NSString *,id> * koMap;
@property (nonatomic,strong) AntBusOC_WKMapTable<id,NSMutableDictionary<NSString *,id> *> * ohMap;
@end

@implementation AntBusOCDataChannel
- (instancetype)init{
    self = [super init];
    if (self) {
        self.koMap = [NSMapTable strongToWeakObjectsMapTable];
        self.ohMap = [[AntBusOC_WKMapTable alloc] init];
    }
    return self;
}
- (void)registerKey:(NSString *)key owner:(id)owner handler:(AntBusOCDataHandlerBlock)handler{
    id oldOwner = [self.koMap objectForKey:key];
    if(oldOwner && oldOwner != owner){
        NSMutableDictionary<NSString *,id> * oldOmhMap = [self.ohMap objectForKey:oldOwner];
        if(oldOmhMap){
            [oldOmhMap removeObjectForKey:key];
        }
    }
    [self.koMap setObject:owner forKey:key];
    NSMutableDictionary<NSString *,id> * omhMap = [self.ohMap objectForKey:owner];
    if(!omhMap){
        omhMap = [NSMutableDictionary new];
    }
    __weak typeof(self) weakself = self;
    [self.ohMap setObject:omhMap forKey:owner hkey:key keyDeallocHandler:^(NSSet<NSString *> * _Nonnull hkeys) {
        for(NSString * hkey in hkeys){
            if(![weakself.koMap objectForKey:hkey]){
                [weakself.koMap removeObjectForKey:hkey];
            }
        }
    }];
    omhMap[key] = handler;
}
- (BOOL)hasCallKey:(NSString *)key owner:(id)owner{
    id _owner = [self.koMap objectForKey:key];
    if(_owner && _owner == owner){
        NSMutableDictionary<NSString *,id> * oldOmhMap = [self.ohMap objectForKey:owner];
        if(oldOmhMap){
            return YES;
        }
    }
    return NO;
}
- (id)callKey:(NSString *)key params:(id)params{
    id owner = [self.koMap objectForKey:key];
    if(owner){
        NSMutableDictionary<NSString *,id> * oldOmhMap = [self.ohMap objectForKey:owner];
        if(oldOmhMap){
            AntBusOCDataHandlerBlock handler = [oldOmhMap objectForKey:key];
            if(handler){
                id result = handler(params);
                return result;
            }
        }
    }
    return nil;
}
- (void)removeKey:(NSString *)key{
    id owner = [self.koMap objectForKey:key];
    if(owner){
        NSMutableDictionary<NSString *,id> * oldOmhMap = [self.ohMap objectForKey:owner];
        if(oldOmhMap){
            [oldOmhMap removeObjectForKey:key];
        }
    }
}
- (void)removeAll{
    [self.koMap removeAllObjects];
    [self.ohMap removeAllObjects];
}
@end

@interface AntBusOCDataChannelV2()

@end

@implementation AntBusOCDataChannelV2

+ (NSString *)createKeyWithProto:(Protocol *)proto selector:(SEL)selector{
    NSString * protoKey = NSStringFromProtocol(proto);
    NSString * selKey = NSStringFromSelector(selector);
    return [NSString stringWithFormat:@"%@.%@",protoKey,selKey];
}
- (void)registerMethod:(Protocol *)proto selector:(SEL)selector owner:(id)owner handler:(AntBusOCDataHandlerBlock)handler{
    NSString * key = [self.class createKeyWithProto:proto selector:selector];
    [AntBusOC.data registerKey:key owner:owner handler:handler];
}
- (id)callMethod:(Protocol *)proto selector:(SEL)selector params:(id)params{
    NSString * key = [self.class createKeyWithProto:proto selector:selector];
    return [AntBusOC.data callKey:key params:params];
}
- (void)removeMethod:(Protocol *)proto selector:(SEL)selector{
    NSString * key = [self.class createKeyWithProto:proto selector:selector];
    [AntBusOC.data removeKey:key];
}
- (void)removeAll{
    [AntBusOC.data removeAll];
}
@end





@interface AntBusOCRouterChannel()
@property (nonatomic,strong) NSMapTable<NSString *,id> * koMap;
@property (nonatomic,strong) AntBusOC_WKMapTable<id,NSMutableDictionary<NSString *,id> *> * ohMap;
@end

@implementation AntBusOCRouterChannel
- (instancetype)init{
    self = [super init];
    if (self) {
        self.koMap = [NSMapTable strongToWeakObjectsMapTable];
        self.ohMap = [[AntBusOC_WKMapTable alloc] init];
    }
    return self;
}
- (void)registerKey:(NSString *)key owner:(id)owner handler:(AntBusOCCallbackHandlerBlock)handler{
    id oldOwner = [self.koMap objectForKey:key];
    if(oldOwner && oldOwner != owner){
        NSMutableDictionary<NSString *,id> * oldOmhMap = [self.ohMap objectForKey:oldOwner];
        if(oldOmhMap){
            [oldOmhMap removeObjectForKey:key];
        }
    }
    [self.koMap setObject:owner forKey:key];
    NSMutableDictionary<NSString *,id> * omhMap = [self.ohMap objectForKey:owner];
    if(!omhMap){
        omhMap = [NSMutableDictionary new];
    }
    __weak typeof(self) weakself = self;
    [self.ohMap setObject:omhMap forKey:owner hkey:key keyDeallocHandler:^(NSSet<NSString *> * _Nonnull hkeys) {
        for(NSString * hkey in hkeys){
            if(![weakself.koMap objectForKey:hkey]){
                [weakself.koMap removeObjectForKey:hkey];
            }
        }
    }];
    omhMap[key] = handler;
}

- (BOOL)callKey:(NSString *)key params:(id)params response:(AntBusOCResponseBlock)response{
    return [self callKey:key params:params response:response result:nil];
}

- (BOOL)callKey:(NSString * _Nonnull)key params:(id _Nullable)params response:(AntBusOCResponseBlock _Nullable)response result:(AntBusOCResultBlock _Nullable)result{
    id owner = [self.koMap objectForKey:key];
    if(owner){
        NSMutableDictionary<NSString *,id> * oldOmhMap = [self.ohMap objectForKey:owner];
        if(oldOmhMap){
            AntBusOCCallbackHandlerBlock handler = [oldOmhMap objectForKey:key];
            handler(params,^(id data){
                if(response){
                    response(data);
                }
            },^(id data){
                if(result){
                    result(data);
                }
            });
            return YES;
        }
    }
    return NO;
}
- (void)removeKey:(NSString *)key{
    id owner = [self.koMap objectForKey:key];
    if(owner){
        NSMutableDictionary<NSString *,id> * oldOmhMap = [self.ohMap objectForKey:owner];
        if(oldOmhMap){
            [oldOmhMap removeObjectForKey:owner];
        }
    }
}
- (void)removeAll{
    [self.koMap removeAllObjects];
    [self.ohMap removeAllObjects];
}
@end



@implementation AntBusOCRouterChannelV2

+ (NSString *)createKeyWithProto:(Protocol *)proto selector:(SEL)selector{
    NSString * protoKey = NSStringFromProtocol(proto);
    NSString * selKey = NSStringFromSelector(selector);
    return [NSString stringWithFormat:@"%@.%@",protoKey,selKey];
}

- (void)registerMethod:(Protocol *)proto selector:(SEL)selector owner:(id)owner handler:(AntBusOCCallbackHandlerBlock)handler{
    NSString * key = [self.class createKeyWithProto:proto selector:selector];
    [AntBusOC.router registerKey:key owner:owner handler:handler];
}
- (BOOL)callMethod:(Protocol *)proto selector:(SEL)selector params:(id)params response:(AntBusOCResponseBlock)response{
    NSString * key = [self.class createKeyWithProto:proto selector:selector];
    return [AntBusOC.router callKey:key params:params response:response];
}
- (void)removeMethod:(Protocol *)proto selector:(SEL)selector{
    NSString * key = [self.class createKeyWithProto:proto selector:selector];
    [AntBusOC.router removeKey:key];
}
- (void)removeAll{
    [AntBusOC.router removeAll];
}
@end

//@interface AntBusOCObject()
//@property (nonatomic,strong) NSMapTable<NSString *, id> * koMap;
//@property (nonatomic,strong) AntBusOC_WKMapTable<id,NSMutableDictionary *> * ooMap;
//@end
//
//@implementation AntBusOCObject
//
//- (instancetype)init
//{
//    self = [super init];
//    if (self) {
//        self.koMap = [NSMapTable strongToWeakObjectsMapTable];
//        self.ooMap = [AntBusOC_WKMapTable<id, NSMutableDictionary *> new];
//    }
//    return self;
//}
//
//- (void)registerObject:(id)obj owner:(id)owner{
//    NSString * key = NSStringFromClass([obj class]);
//    [self.koMap setObject:owner forKey:key];
//    NSMutableDictionary * objs = [self.ooMap objectForKey:owner];
//    if(!objs){
//        objs = [NSMutableDictionary new];
//    }
//    __weak typeof(self) weakSelf = self;
//    [self.ooMap setObject:objs forKey:owner hkey:key keyDeallocHandler:^(NSSet<NSString *> * _Nonnull hkeys) {
//        for(NSString * hkey in hkeys){
//            if(![weakSelf.koMap objectForKey:hkey]){
//                [weakSelf.koMap removeObjectForKey:hkey];
//            }
//        }
//    }];
//    [objs setValue:obj forKey:key];
//}
//
//- (id)objectForType:(Class)clazz{
//    NSString * key = NSStringFromClass(clazz);
//    id owner = [self.koMap objectForKey:key];
//    NSMutableDictionary * objs = [self.ooMap objectForKey:owner];
//    return [objs valueForKey:key];
//}
//
//- (void)removeForType:(Class)type{
//    NSString * key = NSStringFromClass(type);
//    id owner = [self.koMap objectForKey:key];
//    NSMutableDictionary * objs = [self.ooMap objectForKey:owner];
//    [objs removeObjectForKey:key];
//}
//
//@end


@implementation AntBusOC

+ (AntBusOCNotiChannel *)notification{
    static AntBusOCNotiChannel * instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[AntBusOCNotiChannel alloc] init];
    });
    return instance;
}

+ (AntBusOCDataChannel *)data{
    static AntBusOCDataChannel * instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[AntBusOCDataChannel alloc] init];
    });
    return instance;
}

+ (AntBusOCDataChannelV2 *)dataV2{
    static AntBusOCDataChannelV2 * instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[AntBusOCDataChannelV2 alloc] init];
    });
    return instance;
}

+ (AntBusOCRouterChannel *)router{
    static AntBusOCRouterChannel * instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[AntBusOCRouterChannel alloc] init];
    });
    return instance;
}

+ (AntBusOCRouterChannelV2 *)routerV2{
    static AntBusOCRouterChannelV2 * instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[AntBusOCRouterChannelV2 alloc] init];
    });
    return instance;
}

//+ (AntBusOCObject *)object{
//    static AntBusOCObject * instance = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        instance = [[AntBusOCObject alloc] init];
//    });
//    return instance;
//}

+ (AntBusOCChannel *)channel{
    static AntBusOCChannel * instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[AntBusOCChannel alloc] init];
    });
    return instance;
}

@end




