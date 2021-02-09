#ifndef SKBAdView_h
#define SKBAdView_h

#import <UIKit/UIKit.h>
#import "OneAdEvent.h"

@protocol OneAdEventDelegate <NSObject>
- (void)handleAdEvent:(OneAdEvent *)event;
@end

/**
 광고를 요청하고 얻는 비디오 광고를 플레이할 UIView.
 */
@interface OneAdView : UIView <NSXMLParserDelegate>

/**
 광고 처리 이벤트를 받기 위한 Delegate
 */
@property(nonatomic, weak) id <OneAdEventDelegate> delegate;

/**
 광고 요청을 하기위한 서버 호출 파라미터.
 */
@property(nonatomic, strong) NSDictionary *params; // 표준 파라미터
@property(nonatomic, strong) NSDictionary *extParams; // 확장 파라미터

/**
 playTime 에 맞는 다음 미드롤 광고의 위치를 얻는다
 */
- (void)prepareAdFromPlayTime:(NSInteger)playTime;

/**
 광고를 동영상 정보를 요청한다.
 */
- (void)prepareAd;

/**
 광고 동영상을 표시한다.
 */
- (void)playAd;

/**
 번들 이미지 경로를 지정하여 회전할 indicator image를 지정한다..
 */
- (void)setProgressImageResource:(NSString *)path;

/**
 Indicator 가 시작되는 시간 delay millisec초를 지정한다.
 */
- (void)setLoadingImagePresentDelay:(NSInteger)delayMillis;

/**
 view 와 관련된 시스템 리소스를 해제한다. 이 뷰를 이후 사용할 수 없다.
 */
- (void)dispose;

/**
 * FIXME: skb 요청에 의한 테스트 코드
 */
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event;

@end

#endif /* SKBAdView_h */
