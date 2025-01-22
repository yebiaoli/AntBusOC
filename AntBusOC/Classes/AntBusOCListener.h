#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^AntBusOCListenerCallBack)(id _Nullable oldVal, id _Nullable newVal);


@interface AntBusOCListener : NSObject
- (void)listeningKeyPath:(NSString *)keyPath forObject:(NSObject *)object handler:(AntBusOCListenerCallBack _Nonnull)handler;
- (void)removeListeningKeyPath:(NSString *)keyPath forObject:(NSObject *)object;
@end

NS_ASSUME_NONNULL_END
