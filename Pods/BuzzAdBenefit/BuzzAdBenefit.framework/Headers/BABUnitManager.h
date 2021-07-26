#import <Foundation/Foundation.h>

@class BABUnitSetting;

NS_ASSUME_NONNULL_BEGIN

@interface BABUnitManager : NSObject

@property (nonatomic, copy, readonly) BABUnitSetting *setting;

+ (BABUnitManager *)managerForUnitId:(NSString *)unitId;

@end

NS_ASSUME_NONNULL_END
