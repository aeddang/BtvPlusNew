#import <Foundation/Foundation.h>

@protocol BuzzConfigServiceApi;
@class BuzzConfigParam;
@class BuzzRemoteConfig;

@interface BuzzConfigProvider : NSObject

- (instancetype)initWithParam:(BuzzConfigParam *)param
             configServiceApi:(id<BuzzConfigServiceApi>)configServiceApi;

- (BuzzRemoteConfig *)provideRemoteConfig;

@end
