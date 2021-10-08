#import <Foundation/Foundation.h>
#import <ReactiveObjC/ReactiveObjC.h>

@class BuzzInsightSaveEventRequest;
@class BuzzInsightSaveEventResponse;

@protocol BuzzInsightServiceApi <NSObject>

- (RACSignal<BuzzInsightSaveEventResponse *> *)saveEvents:(BuzzInsightSaveEventRequest *)eventRequest apiKey:(NSString *)apiKey;

@end
