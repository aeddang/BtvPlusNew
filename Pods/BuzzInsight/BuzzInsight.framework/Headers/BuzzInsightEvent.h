#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BuzzInsightEvent : NSObject

@property (nonatomic, copy, readonly) NSString *unitId;
@property (nonatomic, copy, readonly) NSString *type;
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly, nullable) NSDictionary *attributes;
@property (nonatomic, assign, readonly) long createdAt;

+ (instancetype)eventWithUnitId:(NSString *)unitId type:(NSString *)type name:(NSString *)name attributes:(NSDictionary *)attributes createdAt:(long)createdAt;

- (NSDictionary *)toDictionary;

@end

NS_ASSUME_NONNULL_END
