#import <Foundation/Foundation.h>

@interface BuzzApiGetConfigRequest : NSObject

@property (nonatomic, assign) NSUInteger appId;
@property (nonatomic, assign) NSUInteger unitId;
@property (nonatomic, copy) NSString *ifa;
@property (nonatomic, copy) NSString *key;

@end
