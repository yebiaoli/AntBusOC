//
//  AntBusOC.h
//  AntBusOC
//
//  Created by liyebiao on 2021/2/5.
//

#import <Foundation/Foundation.h>
#import "AntBusOCChannel.h"

NS_ASSUME_NONNULL_BEGIN
typedef void (^AntBusOCResponseBlock)(id _Nullable data);
typedef void (^AntBusOCGroupNotiResponseBlock)(NSString * group,NSInteger groupIndex, id _Nullable data, NSMutableDictionary * groupContainer);
typedef void (^AntBusOCResultBlock)(id _Nullable data);
typedef id _Nullable (^AntBusOCDataHandlerBlock)(id _Nullable params);
typedef void (^AntBusOCCallbackHandlerBlock)(id _Nullable params,AntBusOCResponseBlock responseBlock,AntBusOCResultBlock resultBlock);


@interface AntBusOCNotiChannel : NSObject
- (void)registerKey:(NSString * _Nonnull)key owner:(id _Nonnull)owner handler:(AntBusOCResponseBlock _Nonnull)handler;
- (void)callKey:(NSString * _Nonnull)key data:(id _Nullable)data;
- (void)removeKey:(NSString * _Nonnull)key owner:(id _Nonnull)owner;
- (void)removeKey:(NSString * _Nonnull)key;
- (void)removeAll;
@end


@interface AntBusOCDataChannel : NSObject
- (void)registerKey:(NSString * _Nonnull)key owner:(id _Nonnull)owner handler:(AntBusOCDataHandlerBlock _Nonnull)handler;
- (BOOL)hasCallKey:(NSString *)key owner:(id)owner;
- (id _Nullable)callKey:(NSString * _Nonnull)key params:(id _Nullable)params;
- (void)removeKey:(NSString * _Nonnull)key;
- (void)removeAll;
@end

@interface AntBusOCDataChannelV2 : NSObject
- (void)registerMethod:(Protocol * _Nonnull)proto
              selector:(SEL _Nonnull)selector
                 owner:(id _Nonnull)owner
               handler:(AntBusOCDataHandlerBlock _Nonnull)handler;
- (id _Nullable)callMethod:(Protocol * _Nonnull)proto
                  selector:(SEL _Nonnull)selector
                    params:(id _Nullable)params;
- (void)removeMethod:(Protocol * _Nonnull)proto
           selector:(SEL _Nonnull)selector;
- (void)removeAll;
@end


@interface AntBusOCRouterChannel : NSObject
- (void)registerKey:(NSString * _Nonnull)key owner:(id _Nonnull)owner handler:(AntBusOCCallbackHandlerBlock _Nonnull)handler;
- (BOOL)callKey:(NSString * _Nonnull)key params:(id _Nullable)params response:(AntBusOCResponseBlock _Nullable)response;
- (BOOL)callKey:(NSString * _Nonnull)key params:(id _Nullable)params response:(AntBusOCResponseBlock _Nullable)response result:(AntBusOCResultBlock _Nullable)result;
- (void)removeKey:(NSString * _Nonnull)key;
- (void)removeAll;
@end


@interface AntBusOCRouterChannelV2 : NSObject
- (void)registerMethod:(Protocol * _Nonnull)proto
              selector:(SEL _Nonnull)selector
                 owner:(id _Nonnull)owner
               handler:(AntBusOCCallbackHandlerBlock _Nonnull)handler;
- (BOOL)callMethod:(Protocol * _Nonnull)proto
          selector:(SEL _Nonnull)selector
            params:(id _Nullable)params
          response:(AntBusOCResponseBlock _Nullable)response;
- (void)removeMethod:(Protocol * _Nonnull)proto
            selector:(SEL _Nonnull)selector;
- (void)removeAll;
@end


//@interface AntBusOCObject: NSObject
//- (void)registerObject:(id)obj owner:(id)owner;
//- (id)objectForType:(Class)clazz;
//- (void)removeForType:(Class)type;
//@end


@interface AntBusOC : NSObject
+ (AntBusOCNotiChannel *)notification;

+ (AntBusOCDataChannel *)data;
+ (AntBusOCDataChannelV2 *)dataV2;

+ (AntBusOCRouterChannel *)router;
+ (AntBusOCRouterChannelV2 *)routerV2;

//+ (AntBusOCObject *)object;
@property (nonatomic,strong,class,readonly) AntBusOCChannel * channel;

@end



NS_ASSUME_NONNULL_END
