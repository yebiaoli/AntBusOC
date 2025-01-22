#import <Foundation/Foundation.h>
#import "AntBusOCDeallocHook.h"
NS_ASSUME_NONNULL_BEGIN

@interface AntBusOC_WKMapTable<Key,Object> : NSObject

- (Object)objectForKey:(Key)key;

- (void)setObject:(Object _Nullable)object
           forKey:(Key)key
             hkey:(NSString *)kdKey
keyDeallocHandler:(AntBusOCDeallocHookHandler)keyDeallocHandler;

- (void)removeObjectForKey:(Key)key;

- (void)removeAllObjects;

@end

NS_ASSUME_NONNULL_END
