//
//  BuzzVideoPlayerOverlay.h
//  BABNative
//
//  Created by Jaehee Ko on 16/01/2020.
//  Copyright © 2020 Buzzvil. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class BuzzVideoPlayerOverlay;

@protocol BuzzVideoPlayerOverlayDelegate <NSObject>
- (void)BuzzVideoPlayerOverlayDidTappedPlayButton:(BuzzVideoPlayerOverlay *)overlay;
- (void)BuzzVideoPlayerOverlayDidTappedMuteButton:(BuzzVideoPlayerOverlay *)overlay;
- (void)BuzzVideoPlayerOverlayDidTappedFullscreenButton:(BuzzVideoPlayerOverlay *)overlay;
- (void)BuzzVideoPlayerOverlayDidTappedLearnMoreButton:(BuzzVideoPlayerOverlay *)overlay;
@end

@interface BuzzVideoPlayerOverlay : UIView

@property (nonatomic, strong) IBOutlet UIButton *playButton;
@property (nonatomic, strong) IBOutlet UIButton *muteButton;
@property (nonatomic, strong) IBOutlet UIButton *fullscreenButton;
@property (nonatomic, strong) IBOutlet UILabel *remainingTimeLabel;
@property (nonatomic, strong) IBOutlet UIButton *learnMoreButton;
@property (nonatomic, strong) IBOutlet UIButton *replayButton;
@property (nonatomic, weak) id<BuzzVideoPlayerOverlayDelegate> delegate;

- (void)videoPlayTimeUpdated:(NSTimeInterval)currentPlayTime minimumTimeForReward:(NSTimeInterval)minimumTimeForReward videoLength:(NSTimeInterval)videoLength;

@end

NS_ASSUME_NONNULL_END
