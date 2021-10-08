#import <Foundation/Foundation.h>

@interface BuzzInsightSaveEventResponse : NSObject

@property (nonatomic, copy, readonly) NSString *result;
@property (nonatomic, assign, readonly) int putCount;
@property (nonatomic, assign, readonly) int eventPeriod;
@property (nonatomic, copy, readonly) NSArray *eventTypeFilter;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
