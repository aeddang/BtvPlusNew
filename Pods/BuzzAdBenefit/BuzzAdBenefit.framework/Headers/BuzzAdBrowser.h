#import <UIKit/UIKit.h>

@class BuzzLandingInfo;
@class BuzzAdBrowserViewController;
@protocol BuzzAdBrowserEventDelegate;

@interface BuzzAdBrowser : NSObject

+ (BuzzAdBrowser *)sharedInstance;

- (void)setLandingInfo:(BuzzLandingInfo *)landingInfo;

- (void)open;
- (UIViewController *)browserViewController;

- (void)addBrowserEventDelegate:(id<BuzzAdBrowserEventDelegate>)delegate;
- (void)removeBrowserEventDelegate:(id<BuzzAdBrowserEventDelegate>)delegate;

@end
