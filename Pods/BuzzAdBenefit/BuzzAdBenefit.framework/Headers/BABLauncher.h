NS_ASSUME_NONNULL_BEGIN

@class BABAd;
@class BABLaunchInfo;
@protocol BABLauncher;

typedef enum {
  BABLauncherStatusPageLoadFailed = 0,
  BABLauncherStatusLandingConditionNotSatisfied,
  BABLauncherStatusDeepLinkOpened
} BABLauncherStatus;

@protocol BABLauncherEventDelegate <NSObject>

- (void)launcher:(id<BABLauncher>)launcher didLandingSucceededResponse:(BABLaunchInfo *)launchInfo;

- (void)launcher:(id<BABLauncher>)launcher didLandingFailureResponse:(BABLaunchInfo *)launchInfo status:(BABLauncherStatus)status;

- (void)launcher:(id<BABLauncher>)launcher didOpeningExternalBrowserResponse:(BABLaunchInfo *)launchInfo;

@end

@protocol BABLauncher <NSObject>

- (void)openWithLaunchInfo:(BABLaunchInfo *)launchInfo;

- (void)openWithLaunchInfo:(BABLaunchInfo *)launchInfo delegate:(nullable id<BABLauncherEventDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
