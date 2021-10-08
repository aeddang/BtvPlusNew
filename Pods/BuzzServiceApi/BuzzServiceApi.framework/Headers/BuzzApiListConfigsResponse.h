#import <Foundation/Foundation.h>

@class BuzzApiConfig;

@interface BuzzApiListConfigsResponse : NSObject

@property (nonatomic, copy) NSArray<BuzzApiConfig *> *configs;
@property (nonatomic, assign) NSUInteger expiresAt;

@end
