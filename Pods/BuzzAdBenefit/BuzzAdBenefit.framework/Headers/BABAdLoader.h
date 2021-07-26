#import <Foundation/Foundation.h>
#import "BABAd.h"

@class BABAdLoaderParams;
@class BABError;

NS_ASSUME_NONNULL_BEGIN

@interface BABAdLoader : NSObject

@property (nonatomic, copy, readonly) NSString *unitId;
@property (nonatomic, readonly) BOOL isLoading;

- (instancetype)initWithUnitId:(NSString *)unitId;
- (void)loadAdWithOnSuccess:(void (^)(BABAd *ad))onSuccess onFailure:(void (^)(BABError *error))onFailure;
- (void)loadAdsWithSize:(NSUInteger)size onSuccess:(void (^)(NSArray<BABAd *> *ads))onSuccess onFailure:(void (^)(BABError *error))onFailure;
- (void)loadNextAdsWithSize:(NSUInteger)size onSuccess:(void (^)(NSArray<BABAd *> *ads))onSuccess onFailure:(void (^)(BABError *error))onFailure;

- (void)loadAdsWithParams:(BABAdLoaderParams *)params onSuccess:(void (^)(NSArray<BABAd *> *ads))onSuccess onFailure:(void (^)(BABError *error))onFailure;

@end

NS_ASSUME_NONNULL_END
