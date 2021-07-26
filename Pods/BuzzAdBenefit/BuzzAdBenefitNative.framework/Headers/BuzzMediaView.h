//
//  BuzzMediaView.h
//  BuzzMediaView
//
//  Created by Jaehee Ko on 26/12/2018.
//  Copyright © 2018 Buzzvil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BuzzVideoPlayer.h"
#import "BuzzImpressionTrackableView.h"

typedef enum {
  BuzzMediaViewAspectFit,
  BuzzMediaViewAspectFill
} BuzzMediaViewFillMode;

@protocol BuzzPlayerProtocol;

@interface BuzzMediaView : UIView  <BuzzImpressionTrackableView>

@property (nonatomic, readonly) BuzzVideoPlayer *videoPlayer;
@property (nonatomic, assign) BuzzMediaViewFillMode fillMode;

- (void)loadImageAtUrl:(NSURL *)url;
- (void)loadVideoAtUrl:(NSURL *)url autoPlay:(BOOL)autoPlay thumbnailImageUrl:(NSURL *)thumbnailImageUrl fromSecond:(NSTimeInterval)fromSecond mute:(BOOL)mute;
- (void)loadVideoWithBuzzPlayer:(id<BuzzPlayerProtocol>)player autoPlay:(BOOL)autoPlay thumbnailImageUrl:(NSURL *)thumbnailImageUrl;
- (void)loadVideoAtVastTag:(NSString *)vastTag autoPlay:(BOOL)autoPlay thumbnailImageUrl:(NSURL *)thumbnailImageUrl fromSecond:(NSTimeInterval)fromSecond mute:(BOOL)mute;

- (void)didEnterFullscreen;
- (void)didExitFullscreen;

@end
