#import <Foundation/Foundation.h>

@interface BuzzUnitSetting : NSObject

@property(nonatomic, assign, readonly) int baseReward;
@property(nonatomic, assign, readonly) int baseInitPeriod;
@property(nonatomic, assign, readonly) int baseHourLimit;
@property(nonatomic, copy, readonly) NSDictionary *feedRatio;

+ (BuzzUnitSetting *)settingWithBaseReward:(int)baseReward
                            baseInitPeriod:(int)baseInitPeriod
                             baseHourLimit:(int)baseHourLimit
                                 feedRatio:(NSDictionary *)feedRatio;

@end
