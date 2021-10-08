#import <Foundation/Foundation.h>

@class BuzzGetCpsCategoriesUseCase;
@protocol BuzzAdServiceApi;

@interface BuzzAdProvider : NSObject

- (instancetype)initWithServiceApi:(id<BuzzAdServiceApi>)serviceApi;

- (BuzzGetCpsCategoriesUseCase *)getCpsCategoriesUseCase;

@end
