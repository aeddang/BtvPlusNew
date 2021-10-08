#import <Foundation/Foundation.h>
#import <BuzzInsight/BuzzInsightConfig.h>
#import <BuzzInsight/BuzzInsightProvider.h>
#import <BuzzInsight/BuzzInsightSaveEventUseCase.h>
#import <BuzzInsight/BuzzInsightEvent.h>
#import <BuzzInsight/BuzzInsightEventRepository.h>
#import <BuzzInsight/BuzzInsightSaveEventRequest.h>
#import <BuzzInsight/BuzzInsightSaveEventResponse.h>
#import <BuzzInsight/BuzzInsightServiceApi.h>
#import <BuzzInsight/BuzzScreenServiceApi.h>

@class BuzzInsightConfig;
@class BuzzInsightSaveEventUseCase;

@interface BuzzInsight : NSObject

+ (instancetype)insightWithConfig:(BuzzInsightConfig *)config saveEventUseCase:(BuzzInsightSaveEventUseCase *)saveEventUseCase;

- (void)trackEventWithType:(NSString *)type
                      name:(NSString *)name;

- (void)trackEventWithType:(NSString *)type
                      name:(NSString *)name
                attributes:(NSDictionary *)attributes;

- (void)trackEventWithType:(NSString *)type
                      name:(NSString *)name
                    unitId:(NSString *)unitId;

- (void)trackEventWithType:(NSString *)type
                      name:(NSString *)name
                attributes:(NSDictionary *)attributes
                    unitId:(NSString *)unitId;

@end
