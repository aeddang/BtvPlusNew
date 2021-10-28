//
//  PlayerView.h
//  BtvPlus
//
//  Created by DigiCAP on 30/04/2019.
//  Copyright © 2019 skb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface WaterMark : NSObject
- (void)startWatermark:(BOOL)isFirst parent:(UIView *)pParent
                player:(AVPlayer *)pPlayer playerLayer:(AVPlayerLayer *)pPlayerLayer
                  size:(CGSize)pSize stbId:(NSString *)pStbId;
- (void)stopWatermark:(BOOL)stop;
- (void)screenRotationCB:(AVPlayerLayer *)pPlayerLayer;
@end
