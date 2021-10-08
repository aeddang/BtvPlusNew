#import <Foundation/Foundation.h>
#import <ReactiveObjC/ReactiveObjC.h>

@class BuzzInsightEvent;

@protocol BuzzInsightEventRepository <NSObject>

- (RACSignal *)saveEvent:(BuzzInsightEvent *)event;

@end
