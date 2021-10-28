//
//  PlayerView.m
//  BtvPlus
//
//  Created by DigiCAP on 30/04/2019.
//  Copyright © 2019 skb. All rights reserved.
//

#import "WaterMark.h"
#if !TARGET_OS_SIMULATOR
#import <FPInserter/FPInserter.h>
#endif

#define TVOUT_MODE_MSG_TAG       0X7755
#define PADDING                  10

@interface WaterMark ()
{
#if !TARGET_OS_SIMULATOR
    FPInserter    *m_pFpInserter;
#endif

}
@end;

@implementation WaterMark

- (BOOL)decodeHexa:(unsigned char *)src srcLen:(int)srcLen dst:(unsigned char *)dst dstLen:(int)dstLen {
    if (!src || !dst || srcLen <= 0 || dstLen <= 0 || dstLen * 2 != srcLen) {
        return NO;
    }
    unsigned char result[dstLen];
    memset(result, 0, dstLen);
    for (int i = 0; i < dstLen; ++i) {
        unsigned char ch1 = src[i * 2];
        unsigned char ch2 = src[i * 2 + 1];
        unsigned char *sum = &(result[i]);
        if ('0' <= ch1 && ch1 <= '9') {
            *sum = (ch1 - '0');
        } else if ('A' <= ch1 && ch1 <= 'F') {
            *sum = (ch1 - 'A' + 10);
        } else if ('a' <= ch1 && ch1 <= 'f') {
            *sum = (ch1 - 'a' + 10);
        } else {
            return NO;
        }
        *sum <<= 4;
        if ('0' <= ch2 && ch2 <= '9') {
            *sum += (ch2 - '0');
        } else if ('A' <= ch2 && ch2 <= 'F') {
            *sum += (ch2 - 'A' + 10);
        } else if ('a' <= ch2 && ch2 <= 'f') {
            *sum += (ch2 - 'a' + 10);
        } else {
            return NO;
        }
    }
    memcpy(dst, result, dstLen);
    return YES;
}

- (void)startWatermark:(BOOL)isFirst parent:(UIView *)pParent player:(AVPlayer *)pPlayer playerLayer:(AVPlayerLayer *)pPlayerLayer
                  size:(CGSize)pSize stbId:(NSString *)pStbId {
#if !TARGET_OS_SIMULATOR
    if( isFirst) {
        //if( m_bWatermark) {
            if( m_pFpInserter == nil) {
                m_pFpInserter = [[FPInserter alloc] init];
            }
            unsigned char hexaUserCode[32];
            if (pStbId && 38 <= [pStbId length]) {
                NSString *pTrim = [pStbId substringWithRange:NSMakeRange(1, 36)];
                pTrim = [pTrim stringByReplacingOccurrencesOfString:@"-" withString:@""];
                if (32 == [pTrim length]) {
                    memcpy(hexaUserCode, [pTrim cStringUsingEncoding:NSASCIIStringEncoding], 32);
                    unsigned char userCode[16];
                    if ([self decodeHexa:hexaUserCode srcLen:32 dst:userCode dstLen:16]) {
                        int _nResult = [m_pFpInserter initializeFP:pParent
                                                    playerView:pPlayer
                                                          size:pSize
                                                      userCode:userCode
                                                userCodeLength:16];
                        if( _nResult != 0) {
                            //DebugLog(@"FPInserter Init Fail[0x%08x]",_nResult);
                        } else {
                            [m_pFpInserter setIconImage:[UIImage imageNamed:@"player_ico_watermark"]];
                            [m_pFpInserter startFP:pSize];
                        }
                    } else {
                        //DebugLog(@"invalid STB ID: %@", pStbId);
                    }
                } else {
                   // DebugLog(@"invalid STB ID: %@", pStbId);
                }
            } else {
                //DebugLog(@"invalid STB ID: %@", pStbId);
            }
        //}
    }
    [self screenRotationCB:pPlayerLayer];
#endif
}

- (void)stopWatermark:(BOOL)stop
{
#if !TARGET_OS_SIMULATOR
    if(m_pFpInserter) {
        [m_pFpInserter stopFP];
        
        if(stop) {
            [m_pFpInserter finalizeFP];
            m_pFpInserter = nil;
        }
    }
#endif
}

- (void)screenRotationCB:(AVPlayerLayer *)pPlayerLayer
{
#if !TARGET_OS_SIMULATOR
    CGRect _rectVideo = pPlayerLayer.videoRect;
    [m_pFpInserter resizeFP:_rectVideo.size];
#endif
}
@end
