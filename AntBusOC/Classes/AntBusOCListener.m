#import "AntBusOCListener.h"
#import <objc/runtime.h>
#import "AntBusOCDeallocHook.h"

@interface ABOCListenerContainer : NSObject
@property (nonatomic,weak) id target;
@property (nonatomic,strong) NSMutableDictionary<NSString *,NSMutableArray *> * container;
@end
@implementation ABOCListenerContainer
- (void)dealloc{
    NSLog(@"--- dealloc %@ ---",self.class);
}
- (instancetype)initWithTarget:(id)target{
    self = [super init];
    if (self) {
        self.target = target;
        self.container = [NSMutableDictionary new];
    }
    return self;
}
- (void)removeKVO{
    [self.target removeObserver:self];
}
- (void)addMonitoring:(NSString * _Nonnull)keyPath handler:(AntBusOCListenerCallBack _Nonnull)handler{
    NSMutableArray * handlerContainers = [self.container objectForKey:keyPath];
    if(!handlerContainers){
        handlerContainers = [NSMutableArray new];
        [self.container setObject:handlerContainers forKey:keyPath];
        [self.target addObserver:self forKeyPath:keyPath options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:nil];
    }
    [handlerContainers addObject:handler];
}
- (void)removeMonitoring:(NSString * _Nonnull)keyPath{
    NSMutableArray * handlerContainers = [self.container objectForKey:keyPath];
    if(handlerContainers.count > 0){
        [self.target removeObserver:self forKeyPath:keyPath context:nil];
    }
    [self.container removeObjectForKey:keyPath];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    
    id oldVal = change[@"old"];
    id newVal = change[@"new"];
    
    if(![oldVal isEqual:newVal]){
        if([oldVal isKindOfClass:NSNull.class]){
            oldVal = nil;
        }
        if([newVal isKindOfClass:NSNull.class]){
            newVal = nil;
        }
        NSMutableArray * handlerContainers = [self.container objectForKey:keyPath];
        if(handlerContainers){
            for(AntBusOCListenerCallBack handler in handlerContainers){
                handler(oldVal, newVal);
            }
        }
    }
}

@end



@interface NSObject (ABOCListenerContainer)
@property (nonatomic,strong,readonly) ABOCListenerContainer * antbus_listener;
@end
@implementation NSObject (ABOCListenerContainer)
- (ABOCListenerContainer *)antbus_listener{
    ABOCListenerContainer * obj = objc_getAssociatedObject(self, _cmd);
    if(!obj){
        obj = [[ABOCListenerContainer alloc] initWithTarget:self];
        objc_setAssociatedObject(self, @selector(antbus_listener), obj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        [AntBusOCDeallocHook.shared installDeallocHookForObject:self propertyKey:@"NSObject+ABOCListenerContainer" handleKey:@"ABOCListenerContainer" handler:^(NSSet<NSString *> * _Nonnull handlerKeys) {
            [obj removeKVO];
        }];
    }
    return obj;
}
@end



@implementation AntBusOCListener
- (void)listeningKeyPath:(NSString *)keyPath forObject:(NSObject *)object handler:(AntBusOCListenerCallBack _Nonnull)handler{
    [object.antbus_listener addMonitoring:keyPath handler:handler];
}
- (void)removeListeningKeyPath:(NSString *)keyPath forObject:(NSObject *)object{
    [object.antbus_listener removeMonitoring:keyPath];
}
@end
