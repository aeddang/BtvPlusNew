#import <Foundation/Foundation.h>

@interface BuzzInsightConfig : NSObject

@property (nonatomic, assign, readonly) int version;
@property (nonatomic, copy, readonly) NSString *unitId;
@property (nonatomic, copy, readonly) NSString *databaseName;

+ (BuzzInsightConfig *)configWithAppVersion:(int)version unitId:(NSString *)unitId databaseName:(NSString *)databaseName;

@end
