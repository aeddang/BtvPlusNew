#import <Foundation/Foundation.h>

@class BuzzApiBaseReward;

NS_ASSUME_NONNULL_BEGIN

@interface BuzzApiGetBaseRewardsResponse : NSObject

@property (nonatomic, copy, readonly) NSArray<BuzzApiBaseReward *> *baseRewards;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END
