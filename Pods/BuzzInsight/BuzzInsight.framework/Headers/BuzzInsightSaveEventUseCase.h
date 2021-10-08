#import <Foundation/Foundation.h>
#import <ReactiveObjC/ReactiveObjC.h>

@class BuzzInsightEvent;
@protocol BuzzInsightEventRepository;

@interface BuzzInsightSaveEventUseCase : NSObject

- (instancetype)initWithRepository:(id<BuzzInsightEventRepository>)repository;

- (RACSignal *)executeWithEvent:(BuzzInsightEvent *)event;

@end
