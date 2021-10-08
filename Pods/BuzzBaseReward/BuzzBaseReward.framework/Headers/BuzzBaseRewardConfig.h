#import <Foundation/Foundation.h>

@interface BuzzBaseRewardConfig : NSObject

@property (nonatomic, copy, readonly) NSString *appId;
@property (nonatomic, copy, readonly) NSString *accountId;
@property (nonatomic, copy, readonly) NSString *ifa;
@property (nonatomic, copy, readonly) NSString *publisherUserId;

- (instancetype)initWithAppId:(NSString *)appId
                    accountId:(NSString *)accountId
                          ifa:(NSString *)ifa
              publisherUserId:(NSString *)publisherUserId;

@end
