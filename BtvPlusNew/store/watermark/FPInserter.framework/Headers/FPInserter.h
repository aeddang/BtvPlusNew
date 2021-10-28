//
//  FPInserter.h
//  FPInserter
//
//  Created by coretrust on 2016. 2. 16..
//  Copyright © 2016년 coretrust. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#define CTFP_SUCCESS                                0x00000000
#define CTFP_ERROR_INITIALIZE_FAILED                0x00001000
#define CTFP_ERROR_INVALID_PARENTVIEW               0x00001001
#define CTFP_ERROR_INVALID_PLAYER                   0x00001002
#define CTFP_ERROR_INVALID_RESOLUTION               0x00001003
#define CTFP_ERROR_INVALID_USERNUMBER               0x00001004
#define CTFP_ERROR_INVALID_FORMAT_USERNUMBER        0x00001005
#define CTFP_ERROR_INVALID_APPVERSION               0x00001006
#define CTFP_ERROR_INVALID_FORMAT_APPVERSION        0x00001007

@interface FPInserter : UIViewController

/*
 * initialize
 */

- (unsigned int)initializeFP:(UIView *)parentView
                  playerView:(AVPlayer *)playerView
                        size:(CGSize)size
                    userCode:(unsigned char *)userCode
              userCodeLength:(int)length;

- (unsigned int)initializeFP:(UIView *)parentView
                  playerView:(AVPlayer *)playerView
                        size:(CGSize)size
                    userData:(NSData *)userData;



/*
 *  start
 */
- (unsigned int)startFP:(CGSize)size;

/*
 *  stop
 */
- (void)stopFP;

/*
 *  resize
 */
- (unsigned int)resizeFP:(CGSize)size;

/*
 *  finalize
 */
- (void)finalizeFP;

/*
*  setIconImage
*/
- (void)setIconImage:(UIImage *)iconImage;

@end
