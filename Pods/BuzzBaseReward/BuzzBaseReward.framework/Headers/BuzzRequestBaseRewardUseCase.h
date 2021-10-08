#import <Foundation/Foundation.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import "BuzzBaseRewardType.h"

@protocol BuzzBaseRewardRepository;
@class BuzzGetBaseRewardConfigUseCase;
@class BuzzGetMatchingBaseRewardUseCase;

NS_ASSUME_NONNULL_BEGIN

@interface BuzzRequestBaseRewardUseCase : NSObject

- (instancetype)initWithRepository:(id<BuzzBaseRewardRepository>)repository
        getBaseRewardConfigUseCase:(BuzzGetBaseRewardConfigUseCase *)getBaseRewardConfigUseCase
      getMatchingBaseRewardUseCase:(BuzzGetMatchingBaseRewardUseCase *)getMatchingBaseRewardUseCase;

- (RACSignal<NSNumber *> *)executeWithUnitId:(NSString *)unitId type:(BuzzBaseRewardType)type;

@end

NS_ASSUME_NONNULL_END
