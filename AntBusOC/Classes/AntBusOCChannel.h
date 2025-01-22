#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol IAntBusOCChannelSingle <NSObject>
- (void)registerWithInterface:(Protocol * _Nonnull)interface responder:(id _Nonnull)responder;
- (void)registerWithClazz:(Class _Nonnull)clazz responder:(id _Nonnull)responder;

- (id _Nullable)responderWithInterface:(Protocol * _Nonnull)interface;
- (id _Nullable)responderWithClazz:(Class _Nonnull)clazz;

- (void)removeWithInterface:(Protocol * _Nonnull)interface;
- (void)removeWithClazz:(Class _Nonnull)clazz;
- (void)removeAll;
@end


@protocol IAntBusOCChannelMulti <NSObject>
- (void)registerWithInterface:(Protocol * _Nonnull)interface key:(NSString * _Nonnull)key responder:(id _Nonnull)responder;
- (void)registerWithClazz:(Class _Nonnull)clazz key:(NSString * _Nonnull)key responder:(id _Nonnull)responder;

- (NSArray * _Nullable)responderWithInterface:(Protocol * _Nonnull)interface key:(NSString * _Nonnull)key;
- (NSArray * _Nullable)responderWithClazz:(Class _Nonnull)clazz key:(NSString * _Nonnull)key;
- (NSArray * _Nullable)responderWithInterface:(Protocol * _Nonnull)interface;
- (NSArray * _Nullable)responderWithClazz:(Class _Nonnull)clazz;

- (void)removeWithInterface:(Protocol * _Nonnull)interface key:(NSString * _Nonnull)key responder:(id _Nonnull)responder;
- (void)removeWithClazz:(Class _Nonnull)clazz key:(NSString * _Nonnull)key responder:(id _Nonnull)responder;
- (void)removeWithInterface:(Protocol * _Nonnull)interface key:(NSString * _Nonnull)key;
- (void)removeWithClazz:(Class _Nonnull)clazz key:(NSString * _Nonnull)key;
- (void)removeWithInterface:(Protocol * _Nonnull)interface;
- (void)removeWithClazz:(Class _Nonnull)clazz;
- (void)removeAll;
@end

@interface AntBusOCChannel : NSObject
@property (nonatomic,strong,class,readonly) id<IAntBusOCChannelSingle> single;
@property (nonatomic,strong,class,readonly) id<IAntBusOCChannelMulti> multi;
@property (nonatomic,strong,readonly) id<IAntBusOCChannelSingle> single;
@property (nonatomic,strong,readonly) id<IAntBusOCChannelMulti> multi;
@end

NS_ASSUME_NONNULL_END
