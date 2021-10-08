#import <Foundation/Foundation.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import "BuzzBaseRewardType.h"

@class BuzzGetMatchingBaseRewardUseCase;

NS_ASSUME_NONNULL_BEGIN

@interface BuzzGetBaseRewardAmountUseCase : NSObject

- (instancetype)initWithGetMatchingBaseRewardUseCase:(BuzzGetMatchingBaseRewardUseCase *)getMatchingBaseRewardUseCase;

- (RACSignal<NSNumber *> *)executeWithUnitId:(NSString *)unitId type:(BuzzBaseRewardType)type;

@end

NS_ASSUME_NONNULL_END
