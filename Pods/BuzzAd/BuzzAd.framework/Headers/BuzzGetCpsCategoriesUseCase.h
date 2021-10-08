#import <Foundation/Foundation.h>
@import ReactiveObjC;

@protocol BuzzCpsCategoryRepository;

@interface BuzzGetCpsCategoriesUseCase : NSObject

- (instancetype)initWithRepository:(id<BuzzCpsCategoryRepository>)repository;

- (RACSignal<NSArray<NSString *> *> *)execute;

@end
