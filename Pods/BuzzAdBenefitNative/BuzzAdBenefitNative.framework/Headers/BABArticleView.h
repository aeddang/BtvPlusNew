//
//  BABArticleView.h
//  BABNative
//
//  Created by Jaehee Ko on 20/12/2018.
//  Copyright © 2018 Buzzvil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BABArticleViewProtocol.h"
#import "BuzzImpressionTrackableView.h"

NS_ASSUME_NONNULL_BEGIN

@class BABArticle;
@class BABArticleView;
@class BABMediaView;

@protocol BABArticleViewDelegate <NSObject>
@optional
- (void)BABArticleView:(BABArticleView *)adView didImpressArticle:(BABArticle *)article;
- (void)BABArticleView:(BABArticleView *)adView didClickArticle:(BABArticle *)article;
@end

@interface BABArticleView : UIView <BABArticleViewProtocol, BuzzImpressionTrackableView>

@property (nonatomic, weak) id<BABArticleViewDelegate> delegate;
@property (nonatomic, strong) NSArray<UIView *> *clickableViews;
@property (nonatomic, strong) BABArticle *article;

@end

NS_ASSUME_NONNULL_END
