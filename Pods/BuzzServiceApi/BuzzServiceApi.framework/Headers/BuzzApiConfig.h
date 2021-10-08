#import <Foundation/Foundation.h>

@interface BuzzApiConfig : NSObject

@property (nonatomic, copy, readonly) NSString *key;
@property (nonatomic, copy, readonly) NSString *value;

+ (BuzzApiConfig *)configWithDictionary:(NSDictionary *)dictionary;

@end
