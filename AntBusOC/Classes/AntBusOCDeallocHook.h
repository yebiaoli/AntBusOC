#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^AntBusOCDeallocHookHandler)(NSSet<NSString *> * _Nonnull handlerKeys);

@interface AntBusOCDeallocHook : NSObject

+ (AntBusOCDeallocHook *)shared;

- (void)installDeallocHookForObject:(id _Nonnull)obj
                        propertyKey:(NSString * _Nonnull)propertyKey
                          handleKey:(NSString * _Nonnull)handleKey
                            handler:(AntBusOCDeallocHookHandler _Nonnull)handler;

- (void)uninstallDeallocHookForObject:(id _Nonnull)obj
                          propertyKey:(NSString * _Nonnull)propertyKey;

- (void)uninstallDeallocHookForObject:(id _Nonnull)obj
                          propertyKey:(NSString * _Nonnull)propertyKey
                            handleKey:(NSString * _Nonnull)handleKey;


@end

NS_ASSUME_NONNULL_END
