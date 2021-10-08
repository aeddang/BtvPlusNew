#import <Foundation/Foundation.h>

@interface BuzzApiListConfigsRequest : NSObject

@property (nonatomic, assign, readonly) NSUInteger appId;
@property (nonatomic, assign, readonly) NSUInteger unitId;
@property (nonatomic, copy, readonly) NSString *ifa;

- (instancetype)initWithAppId:(NSUInteger)appId
                       unitId:(NSUInteger)unitId
                          ifa:(NSString *)ifa;

@end
