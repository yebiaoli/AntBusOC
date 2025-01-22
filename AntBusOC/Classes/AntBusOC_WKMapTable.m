#import "AntBusOC_WKMapTable.h"
#import <objc/runtime.h>

@interface WeakKey : NSObject<NSCopying>
@property (nonatomic,copy) NSString * objectTypeName;
@property (nonatomic,weak) id object;
@property (nonatomic,assign) NSInteger objectHashValue;
@end

@implementation WeakKey

- (id)copyWithZone:(nullable NSZone *)zone{
    WeakKey * wk = [[WeakKey alloc] initWithObject:self.object];
    return wk;
}

- (instancetype)initWithObject:(id)object{
    self = [super init];
    if (self) {
        self.object = object;
        self.objectHashValue = [object hash];
        self.objectTypeName = NSStringFromClass([object class]);
    }
    return self;
}

- (BOOL)isEqual:(WeakKey *)other
{
    if (other == self) {
        return YES;
    } else if (self.objectHashValue == [other objectHashValue]){
        return YES;
    } else {
        return [super isEqual:other];
    }
}

- (NSUInteger)hash{
    return self.objectHashValue;
}

@end

@interface AntBusOC_WKMapTable()
@property (nonatomic,strong) NSMutableDictionary<id,id> * container;
@property (nonatomic,strong) NSRecursiveLock * lock;
@end

@implementation AntBusOC_WKMapTable

- (void)dealloc{
    for(id key in self.container.allKeys){
        [AntBusOCDeallocHook.shared uninstallDeallocHookForObject:key propertyKey:@"AntBusOC_WKMapTable"];
    }
}

- (NSMutableDictionary<id,id> *)container{
    if(!_container){
        _container = [NSMutableDictionary new];
    }
    return _container;
}

- (NSRecursiveLock *)lock{
    if(!_lock){
        _lock = [NSRecursiveLock new];
    }
    return _lock;
}

- (id)objectForKey:(id)key{
    if(key){
        WeakKey * weekKey = [[WeakKey alloc] initWithObject:key];
        [self.lock lock];
        id obj = [self.container objectForKey:weekKey];
        [self.lock unlock];
        return obj;
    }
    return nil;
}

- (void)setObject:(id _Nullable)object
           forKey:(id)key
             hkey:(NSString *)hkey
keyDeallocHandler:(AntBusOCDeallocHookHandler)keyDeallocHandler{
    if(!object){
        [self removeObjectForKey:key];
        return;
    }
    if(key){
        WeakKey * weekKey = [[WeakKey alloc] initWithObject:key];
        [self.lock lock];
        [self.container setObject:object forKey:weekKey];
        [self installDeallocHook:key weekKey:weekKey hkey:hkey keyDeallocHandler:keyDeallocHandler];
        [self.lock unlock];
    }
}

- (void)removeObjectForKey:(id)key{
    if(key){
        WeakKey * weekKey = [[WeakKey alloc] initWithObject:key];
        [self.lock lock];
        [self.container removeObjectForKey:weekKey];
        [self.lock unlock];
    }
}

- (void)removeAllObjects{
    [self.lock lock];
    [self.container removeAllObjects];
    [self.lock unlock];
}

- (void)installDeallocHook:(id)key
                   weekKey:(WeakKey *)weekKey
                     hkey:(NSString *)hkey
         keyDeallocHandler:(AntBusOCDeallocHookHandler)keyDeallocHandler{
    
    __weak typeof(self) weakself = self;
    [AntBusOCDeallocHook.shared installDeallocHookForObject:key propertyKey:@"AntBusOC_WKMapTable" handleKey:hkey handler:^(NSSet<NSString *> * _Nonnull handlerKeys) {
        [weakself.lock lock];
        [weakself.container removeObjectForKey:weekKey];
        [weakself.lock unlock];
        if(keyDeallocHandler){
            keyDeallocHandler(handlerKeys);
        }
    }];
}

@end
