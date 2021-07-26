#import <Foundation/Foundation.h>
#import <BuzzAdBenefit/BABConfig.h>
#import <BuzzAdBenefit/BABUserProfile.h>
#import <BuzzAdBenefit/BABUserPreference.h>
#import <BuzzAdBenefit/BABAdLoader.h>
#import <BuzzAdBenefit/BABAd.h>
#import <BuzzAdBenefit/BABAdLoaderParams.h>
#import <BuzzAdBenefit/BABCreative.h>
#import <BuzzAdBenefit/BABVideoAdMetadata.h>
#import <BuzzAdBenefit/BABVideoAdMetadataLoader.h>
#import <BuzzAdBenefit/BABTracker.h>
#import <BuzzAdBenefit/BABReachability.h>
#import <BuzzAdBenefit/BABLauncher.h>
#import <BuzzAdBenefit/BABLaunchInfo.h>
#import <BuzzAdBenefit/BABArticleLoader.h>
#import <BuzzAdBenefit/BABArticle.h>
#import <BuzzAdBenefit/BABRewardHandler.h>
#import <BuzzAdBenefit/BABLogger.h>
#import <BuzzAdBenefit/BABError.h>
#import <BuzzAdBenefit/BABDeviceInfo.h>
#import <BuzzAdBenefit/BABSession.h>
#import <BuzzAdBenefit/BABPointConfig.h>
#import <BuzzAdBenefit/BABBridgePointConfig.h>
#import <BuzzAdBenefit/BABUnitSetting.h>
#import <BuzzAdBenefit/BABUnitManager.h>
#import <BuzzAdBenefit/BuzzAdBrowser.h>
#import <BuzzAdBenefit/BuzzAdBrowserViewController.h>
#import <BuzzAdBenefit/BuzzAdBrowserEventDelegate.h>
#import <BuzzAdBenefit/BuzzLandingInfo.h>
#import <BuzzAdBenefit/BuzzEvent.h>
#import <BuzzAdBenefit/BuzzReward.h>

NS_ASSUME_NONNULL_BEGIN

@class BABConfig;
@class BABUserProfile;
@class BABUserPreference;
@class UIViewController;
@class BABError;

extern NSString *const BABSessionRegisteredNotification;

@interface BuzzAdBenefit: NSObject

@property (nonatomic, readonly, nullable) BABConfig *config;
@property (nonatomic, readonly, nullable) BABUserProfile *userProfile;
@property (nonatomic, readonly, nullable) BABUserPreference *userPreference;
@property (nonatomic, readonly) id<BABLauncher> launcher;

+ (BuzzAdBenefit *)sharedInstance;
+ (void)initializeWithConfig:(BABConfig *)config;
+ (void)setUserProfile:(nullable BABUserProfile *)userProfile;
+ (void)setUserProfile:(nullable BABUserProfile *)userProfile shouldShowAppTrackingTransparencyDialog:(BOOL)shouldShowAppTrackingTransparencyDialog;
+ (void)setUserPreference:(nullable BABUserPreference *)userPreference;
+ (void)setLauncher:(nullable id<BABLauncher>)launcher;
+ (void)showInquiryPageOnViewController:(UIViewController *)viewController;
- (void)getCurrentPointOnSuccess:(void (^)(int))onSuccess onFailure:(void (^)(NSError *))onFailure;
- (void)getPointConfigOnSuccess:(void (^)(BABPointConfig *))onSuccess onFailure:(void (^)(NSError *))onFailure;
- (void)showCurrentPointDialogOnViewController:(UIViewController *)viewController;
- (void)showCurrentPointDialogOnViewController:(UIViewController *)viewController config:(nullable BABBridgePointConfig *)config;

@end

NS_ASSUME_NONNULL_END
