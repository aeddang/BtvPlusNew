#import <Foundation/Foundation.h>

@protocol BuzzBaseRewardConfigService;
@protocol BuzzBaseRewardServiceApi;
@class BuzzGetBaseRewardAmountUseCase;
@class BuzzRequestBaseRewardUseCase;

NS_ASSUME_NONNULL_BEGIN

@interface BuzzBaseRewardProvider : NSObject

- (instancetype)initWithConfigService:(id<BuzzBaseRewardConfigService>)configService
                           serviceApi:(id<BuzzBaseRewardServiceApi>)serviceApi;

- (BuzzGetBaseRewardAmountUseCase *)provideGetBaseRewardAmountUseCase;

- (BuzzRequestBaseRewardUseCase *)provideRequestBaseRewardUseCase;

@end

NS_ASSUME_NONNULL_END
