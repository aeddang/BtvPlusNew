#import <Foundation/Foundation.h>

@interface BuzzApiUnitSettingResponse : NSObject

@property(nonatomic, assign) int baseReward;
@property(nonatomic, assign) int baseInitPeriod;
@property(nonatomic, assign) int baseHourLimit;
@property(nonatomic, copy) NSDictionary *feedRatio;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
