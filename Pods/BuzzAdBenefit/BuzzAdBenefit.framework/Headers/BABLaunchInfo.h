#import <Foundation/Foundation.h>

@class BABAd;
@class BABArticle;

NS_ASSUME_NONNULL_BEGIN

@interface BABLaunchInfo : NSObject

@property (nonatomic, copy, readonly) NSURL *url;
@property (nonatomic, copy, nullable, readonly) BABAd *ad;
@property (nonatomic, copy, nullable, readonly) BABArticle *article;
@property (nonatomic, assign, readonly) BOOL shouldLandingExternalBrowser;

- (instancetype)initWithURL:(NSURL *)url ad:(nullable BABAd *)ad article:(nullable BABArticle *)article shouldLandingExternalBrowser:(BOOL)shouldLandingExternalBrowser;

@end

NS_ASSUME_NONNULL_END
