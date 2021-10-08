#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, BuzzApiBaseRewardResourceType) {
  BuzzApiBaseRewardResourceTypeNone,
  BuzzApiBaseRewardResourceTypeAd,
  BuzzApiBaseRewardResourceTypeArticle,
  BuzzApiBaseRewardResourceTypePedometer,
  BuzzApiBaseRewardResourceTypeLottery,
  BuzzApiBaseRewardResourceTypeFeed,
};

@interface BuzzApiBaseRewardResource : NSObject

@property (nonatomic, copy, readonly) NSString *resourceId;
@property (nonatomic, assign, readonly) BuzzApiBaseRewardResourceType resourceType;

- (instancetype)initWithResourceId:(NSString *)resourceId
                      resourceType:(BuzzApiBaseRewardResourceType)resourceType;

@end

NS_ASSUME_NONNULL_END
