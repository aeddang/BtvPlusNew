#import <Foundation/Foundation.h>
@import ReactiveObjC;

@class BuzzUnitSetting;
@protocol BuzzUnitServiceApi;

@interface BuzzUnitUseCase : NSObject

- (instancetype)initWithServiceApi:(id<BuzzUnitServiceApi>)serviceApi;

- (RACSignal<BuzzUnitSetting *> *)getUnitSettingWithUnitId:(NSString *)unitId;

@end
