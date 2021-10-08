#import <Foundation/Foundation.h>
#import <ReactiveObjC/ReactiveObjC.h>

@class BuzzBaseRewardConfig;

@protocol BuzzBaseRewardConfigService <NSObject>

- (RACSignal<BuzzBaseRewardConfig *> *)getBaseRewardConfig;

@end
