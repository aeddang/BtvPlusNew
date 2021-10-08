#import <Foundation/Foundation.h>
@import ReactiveObjC;

@protocol BuzzAdServiceApi <NSObject>

- (RACSignal<NSArray<NSString *> *> *)getCpsCategories;

@end
