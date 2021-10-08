#import <Foundation/Foundation.h>

@interface BuzzConfigParam : NSObject

@property (nonatomic, copy, readonly) NSString *appId;
@property (nonatomic, copy, readonly) NSString *unitId;
@property (nonatomic, copy, readonly) NSString *ifa;
@property (nonatomic, copy, readonly) NSDictionary *defaultValues;

+ (BuzzConfigParam *)paramWithAppId:(NSString *)appId
                             unitId:(NSString *)unitId
                                ifa:(NSString *)ifa
                      defaultValues:(NSDictionary *)defaultValues;

@end
