#import <UIKit/UIKit.h>

@class BABInterstitialConfig;
@class BABInterstitialAdHandler;
@class BABError;

NS_ASSUME_NONNULL_BEGIN

typedef enum {
  BABInterstitialDialog,
  BABInterstitialBottomSheet
} BABInterstitialType;

@protocol BABInterstitialAdHandlerDelegate <NSObject>
- (void)BABInterstitialAdHandler:(BABInterstitialAdHandler *)adLoader didFailToLoadAdWithError:(BABError *)error;
- (void)BABInterstitialAdHandlerDidSucceedLoadingAd:(BABInterstitialAdHandler *)adLoader;
@optional
- (void)BABInterstitialViewControllerDidFinish:(UIViewController *)viewController;
@end

@interface BABInterstitialAdHandler : NSObject

@property (nonatomic, weak) id<BABInterstitialAdHandlerDelegate> delegate;

- (instancetype)initWithUnitId:(NSString *)unitId type:(BABInterstitialType)type;
- (void)show:(UIViewController *)presentingViewController withConfig:(nullable BABInterstitialConfig *)config;

@end

NS_ASSUME_NONNULL_END
