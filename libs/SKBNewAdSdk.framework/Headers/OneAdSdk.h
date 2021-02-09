#import <Foundation/Foundation.h>
#import "OneAdView.h"
#import "OneAdEvent.h"

@interface OneAdSdk : NSObject

/**
 * Singleton 인스턴스 생성 또는 반환
 */
+ (id)sharedInstance;

+ (id)initializeWithMediaId:(NSString *)mediaId accessKey:(NSString *)accessKey;

- (NSString *)mediaId;

- (NSString *)accessKey;

- (NSString *)osType;

- (NSString *)osVersion;

- (NSString *)modelName;

- (NSString *)deviceId;

/**
 * 개발/상용에 맞는 환경을 설정
 */
+ (void)setEnvironment:(OneAdSdkEnvironment)environment;

+ (void)setDebug:(BOOL)useDebug;

+ (void)L:(NSString *)format, ...;

+ (void)logBuildInfo;

- (BOOL)initPairingInfo:(NSDictionary *)authRespDic;

@end




