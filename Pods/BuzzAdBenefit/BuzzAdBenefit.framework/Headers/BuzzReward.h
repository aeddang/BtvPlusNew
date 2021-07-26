#import <Foundation/Foundation.h>

typedef enum {
  BuzzRewardStatusReceivable,
  BuzzRewardStatusAlreadyReceived,
  BuzzRewardStatusUnknown
} BuzzRewardStatus;

extern NSString * const kExtraMinimumStayDuration;

@interface BuzzReward : NSObject

@property (nonatomic, copy, readonly) NSString *issueMethod;
@property (nonatomic, assign, readonly) NSUInteger amount;
@property (nonatomic, assign) BuzzRewardStatus status;
@property (nonatomic, copy, readonly) NSString *statusCheckUrl;
@property (nonatomic, assign, readonly) NSUInteger ttl;
@property (nonatomic, copy, readonly) NSDictionary *extra;

- (instancetype)initWithDictionary:(NSDictionary *)dic;

- (NSUInteger)getReceivableAmount;

- (BOOL)isReceivable;

- (void)markAsRewarded;

- (BOOL)isRewarded;

@end
