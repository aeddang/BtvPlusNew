#import <UIKit/UIKit.h>

@class BABFeedConfig;
@class BABFeedProvider;
@class BABFeedHeaderView;

NS_ASSUME_NONNULL_BEGIN

@interface BABFeedViewController : UIViewController

@property (nonatomic) BABFeedConfig *config;
@property (nonatomic, strong) BABFeedProvider *provider;

@property (nonatomic, assign) BOOL shouldOverrideTopInset;
@property (nonatomic, assign) CGFloat topInset;

- (void)scrollToTop;

@end

NS_ASSUME_NONNULL_END
