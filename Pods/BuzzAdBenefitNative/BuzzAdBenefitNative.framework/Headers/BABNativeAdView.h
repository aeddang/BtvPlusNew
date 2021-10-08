#import <UIKit/UIKit.h>
#import <BuzzAdBenefit/BABRewardResult.h>
#import "BABNativeAdViewProtocol.h"
#import "BuzzImpressionTrackableView.h"

NS_ASSUME_NONNULL_BEGIN

@class BABAd;
@class BABNativeAdView;
@class BABMediaView;

@protocol BABNativeAdViewDelegate <NSObject>

- (void)BABNativeAdView:(BABNativeAdView *)adView willRequestRewardForAd:(BABAd *)ad;
- (void)BABNativeAdView:(BABNativeAdView *)adView didRewardForAd:(BABAd *)ad withResult:(BABRewardResult)result;
- (void)BABNativeAdView:(BABNativeAdView *)adView didParticipateAd:(BABAd *)ad;

@optional
- (UIViewController *)BABNativeAdViewViewControlleForPresentingFullscreen;
- (void)BABNativeAdView:(BABNativeAdView *)adView didImpressAd:(BABAd *)ad;
- (BOOL)BABNativeAdView:(BABNativeAdView *)adView shouldClickAd:(BABAd *)ad;
- (void)BABNativeAdView:(BABNativeAdView *)adView didClickAd:(BABAd *)ad;
- (void)BABNativeAdView:(BABNativeAdView *)adView didWillOpenLandingPageForAd:(BABAd *)ad;

@end

@protocol BABNativeAdViewVideoDelegate <NSObject>
@optional
- (void)BABNativeAdViewWillStartPlayingVideo:(BABNativeAdView *)adView;
- (void)BABNativeAdViewDidResumeVideo:(BABNativeAdView *)adView;
- (void)BABNativeAdViewWillReplayVideo:(BABNativeAdView *)adView;
- (void)BABNativeAdViewDidPauseVideo:(BABNativeAdView *)adView;
- (void)BABNativeAdView:(BABNativeAdView *)adView didFinishPlayingVideoAd:(BABAd *)ad;
@end

@interface BABNativeAdView : UIView <BABNativeAdViewProtocol, BuzzImpressionTrackableView>

@property (nonatomic, weak) id<BABNativeAdViewDelegate> delegate;
@property (nonatomic, weak) id<BABNativeAdViewVideoDelegate> videoDelegate;
@property (nonatomic, strong) BABMediaView *mediaView;
@property (nonatomic, strong) NSArray<UIView *> *clickableViews;
@property (nonatomic, strong) BABAd *ad;

@end

NS_ASSUME_NONNULL_END
