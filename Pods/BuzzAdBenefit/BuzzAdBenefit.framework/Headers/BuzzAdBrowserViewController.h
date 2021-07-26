#import <UIKit/UIKit.h>

@class BuzzLandingInfo;
@protocol BuzzAdBrowserEventDelegate;

@interface BuzzAdBrowserViewController : UIViewController

- (instancetype)initWithLandingInfo:(BuzzLandingInfo *)landingInfo
                      eventDelegate:(id<BuzzAdBrowserEventDelegate>) delegate;

@end
