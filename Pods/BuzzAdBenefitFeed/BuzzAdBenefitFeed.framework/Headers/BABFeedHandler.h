#import <UIKit/UIKit.h>
#import "BABFeedViewController.h"

@class BABFeedConfig;
@class BABError;

@class BABNewFeedViewController;

NS_ASSUME_NONNULL_BEGIN

@interface BABFeedHandler : NSObject

@property (nonatomic, readonly) NSUInteger adsCount;
@property (nonatomic, readonly) double availableReward;

- (instancetype)initWithConfig:(BABFeedConfig *)config;
- (void)preloadWithOnSuccess:(void (^)(void))onSuccess onFailure:(void (^)(BABError *error))onFailure;
- (BABFeedViewController *)populateViewController;

@end

NS_ASSUME_NONNULL_END
