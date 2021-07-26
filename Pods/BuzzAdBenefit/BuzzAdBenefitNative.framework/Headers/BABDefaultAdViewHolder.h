#import <UIKit/UIKit.h>
#import "BABAdViewHolder.h"
#import "BABStateValue.h"

NS_ASSUME_NONNULL_BEGIN

@interface BABDefaultAdViewHolder : BABAdViewHolder

@property (nonatomic, strong) BABStateValue<UIImage *> *ctaViewIcon;
@property (nonatomic, strong) BABStateValue<UIColor *> *ctaViewBackgroundColor;
@property (nonatomic, strong) BABStateValue<UIColor *> *ctaViewTextColor;

@property (nonatomic, assign) CGFloat detailViewPadding;
@property (nonatomic, assign) CGFloat mediaViewCornerRadius;

+ (NSString *)nibName;

@end

NS_ASSUME_NONNULL_END
