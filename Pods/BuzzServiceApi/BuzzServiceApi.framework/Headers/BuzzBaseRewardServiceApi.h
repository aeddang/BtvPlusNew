#import <Foundation/Foundation.h>
@import ReactiveObjC;

#import <BuzzServiceApi/BuzzApiBaseReward.h>
#import <BuzzServiceApi/BuzzApiBaseRewardResource.h>
#import <BuzzServiceApi/BuzzApiGetBaseRewardsRequest.h>
#import <BuzzServiceApi/BuzzApiGetBaseRewardsResponse.h>
#import <BuzzServiceApi/BuzzApiRequestBaseRewardRequest.h>

@protocol BuzzBaseRewardServiceApi <NSObject>

- (RACSignal<BuzzApiGetBaseRewardsResponse *> *)getBaseRewardsWithRequest:(BuzzApiGetBaseRewardsRequest *)request;

- (RACSignal *)requestBaseRewardWithRequest:(BuzzApiRequestBaseRewardRequest *)request;

@end
