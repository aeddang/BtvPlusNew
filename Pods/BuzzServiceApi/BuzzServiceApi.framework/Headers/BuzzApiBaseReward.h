#import <Foundation/Foundation.h>

@class BuzzApiBaseRewardResource;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, BuzzApiBaseRewardEventType) {
  BuzzApiBaseRewardEventTypeNone,
  BuzzApiBaseRewardEventTypeLanded,
  BuzzApiBaseRewardEventTypeAction,
  BuzzApiBaseRewardEventTypeWalked,
  BuzzApiBaseRewardEventTypeWon,
  BuzzApiBaseRewardEventTypeOpened,
};

@interface BuzzApiBaseReward : NSObject

@property (nonatomic, assign, readonly) NSInteger amount;
@property (nonatomic, assign, readonly) BuzzApiBaseRewardEventType eventType;
@property (nonatomic, assign, readonly) NSInteger eventTypeDeprecated;
@property (nonatomic, copy, readonly) NSDictionary *extra;
@property (nonatomic, copy, readonly) NSString *issueMethod;
@property (nonatomic, copy, readonly) BuzzApiBaseRewardResource *resource;
@property (nonatomic, assign, readonly) NSInteger status;
@property (nonatomic, copy, readonly) NSString *transactionId;
@property (nonatomic, assign, readonly) NSInteger ttl;

- (instancetype)initWithAmount:(NSInteger)amount
                     eventType:(BuzzApiBaseRewardEventType)eventType
           eventTypeDeprecated:(NSInteger)eventTypeDeprecated
                         extra:(NSDictionary *)extra
                   issueMethod:(NSString *)issueMethod
                      resource:(BuzzApiBaseRewardResource *)resource
                        status:(NSInteger)status
                 transactionId:(NSString *)transactionId
                           ttl:(NSInteger)ttl;

@end

NS_ASSUME_NONNULL_END
