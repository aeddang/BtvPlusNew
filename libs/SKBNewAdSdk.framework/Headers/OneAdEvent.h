#ifndef SKBAdEvent_h
#define SKBAdEvent_h

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, OneAdEventType) {
    DidReceiveAd, //ad request 가 완료되어 ad 정보를 얻은 경우, 가능한 에러코드: ok
    FailReceiveAd, //ad request 후 어떤 에러로 ad 정보를 얻지 못한 경우, 가능한 에러코드: network, internal, server
    FinishAd, //duration 까지 ad 가 플레이 된 경우, 가능한 에러코드: ok, network, internal, server, player
    StopAd, //duration 까지 ad 를 플레이하지 못한채 중지된 경우, 가능한 에러코드: ok, network, internal, server, player
    SkipAd, //사용자가 스킵버튼을 누른 경우, 가능한 에러코드: ok
    NotExistReceiveAd, //서버에서 정상적으로 Ad 를 보내지 않은 경우, 가능한 에러코드: ok
    ClickAd, //더보기 클릭 CloseLandingPage 이벤트 발생, 가능한 에러코드: ok
    CloseLandingPage //이벤트 뒤에 광고 url 을 방문하고 돌아왔을 때, 가능한 에러코드: ok
};

typedef NS_ENUM(NSInteger, OneAdErrorCode) {
    OK, //
    NetworkError, //네트워크 문제로 발생된 에러.
    InternalError, //내부에러
    InvalidError, //SDK interface 관련 잘못된 인수및 잘못된 호출 에러.
    ServerError, //Ad request 에서 서버쪽 발생 에러.
    PlayerError //Ad 를 플레이하는 MediaPlayer 에서 발생하는 에러.
};

typedef NS_ENUM(NSInteger, OneAdSdkEnvironment) {
    DEV = 1, //개발환경
    PROD = 2, //상용
    STAGE = 3
};

@interface OneAdEvent : NSObject

@property(nonatomic, assign) OneAdEventType eventType;

@property(nonatomic, assign) OneAdErrorCode errorCode;

@property(nonatomic, assign) NSInteger adPrepareTimeMs;

@end

#endif /* SKBAdEvent_h */
