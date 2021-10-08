#import <Foundation/Foundation.h>

@interface BuzzUserAgent : NSObject

+ (NSString *)buildUserAgentWithSdkName:(NSString *)sdkName
                             sdkVersion:(NSString *)sdkVersion
                         sdkVersionCode:(NSString *)sdkVersionCode
                                appName:(NSString *)appName
                             appVersion:(NSString *)appVersion
                         appVersionCode:(NSString *)appVersionCode
                              osVersion:(NSString *)osVersion
                          osVersionCode:(NSString *)osVersionCode
                                  model:(NSString *)model
                           manufacturer:(NSString *)manufacturer
                                 device:(NSString *)device
                                  brand:(NSString *)brand
                                product:(NSString *)product;

@end
