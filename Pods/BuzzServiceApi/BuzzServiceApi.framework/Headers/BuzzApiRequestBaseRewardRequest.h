#import <Foundation/Foundation.h>

@interface BuzzApiRequestBaseRewardRequest : NSObject

@property (nonatomic, copy, readonly) NSString *appId;
@property (nonatomic, copy, readonly) NSString *unitId;
@property (nonatomic, copy, readonly) NSString *accountId;
@property (nonatomic, copy, readonly) NSString *ifa;
@property (nonatomic, copy, readonly) NSString *publisherUserId;
@property (nonatomic, copy, readonly) NSString *transactionId;

- (instancetype)initWithAppId:(NSString *)appId
                       unitId:(NSString *)unitId
                    accountId:(NSString *)accountId
                          ifa:(NSString *)ifa
              publsiherUserId:(NSString *)publisherUserId
                transactionId:(NSString *)transactionId;

- (NSDictionary *)toDictionary;

@end
