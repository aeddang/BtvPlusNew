#import <Foundation/Foundation.h>
@import ReactiveObjC;

#import <BuzzServiceApi/BuzzApiUnitSettingResponse.h>

@class BuzzApiUnitSettingResponse;

@protocol BuzzUnitServiceApi <NSObject>

- (RACSignal<BuzzApiUnitSettingResponse *> *)getUnitSettingWithUnitId:(NSString *)unitId;

@end
