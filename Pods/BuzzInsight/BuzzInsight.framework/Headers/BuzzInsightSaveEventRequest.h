#import <Foundation/Foundation.h>

@interface BuzzInsightSaveEventRequest : NSObject

@property (nonatomic, assign, readonly) int version;
@property (nonatomic, copy, readonly) NSString *guid;
@property (nonatomic, assign, readonly) int timestamp;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *subUserId;
@property (nonatomic, assign) int appId;
@property (nonatomic, assign) int unitId;
@property (nonatomic, assign) int organizationId;
@property (nonatomic, copy) NSString *ifa;
@property (nonatomic, copy) NSString *udid;
@property (nonatomic, copy) NSString *country;
@property (nonatomic, copy) NSString *deviceOs;
@property (nonatomic, copy) NSString *deviceName;
@property (nonatomic, copy) NSString *deviceResolution;
@property (nonatomic, copy) NSString *sex;
@property (nonatomic, assign) int yearOfBirth;
@property (nonatomic, copy) NSString *carrier;
@property (nonatomic, copy) NSArray<NSDictionary *> *events;

- (instancetype)initWithVersion:(int)version guid:(NSString *)guid timestamp:(int)timestamp;

- (NSDictionary *)toDictionary;

@end
