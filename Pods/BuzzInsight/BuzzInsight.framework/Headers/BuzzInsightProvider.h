#import <Foundation/Foundation.h>

@class BuzzInsight;
@class BuzzInsightConfig;
@protocol BuzzInsightServiceApi;
@protocol BuzzScreenServiceApi;

@interface BuzzInsightProvider : NSObject

- (instancetype)initWithConfig:(BuzzInsightConfig *)config
             insightServiceApi:(id<BuzzInsightServiceApi>)insightServiceApi
          buzzScreenServiceApi:(id<BuzzScreenServiceApi>)buzzScreenServiceApi;

- (BuzzInsight *)buzzInsight;

@end
