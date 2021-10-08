#import <Foundation/Foundation.h>
@import ReactiveObjC;

@protocol BuzzConfigRepository;

@interface BuzzRemoteConfig : NSObject

@property (nonatomic, copy) NSDictionary *defaultValues;

- (instancetype)initWithRepository:(id<BuzzConfigRepository>)repository defaultValues:(NSDictionary *)defaultValues;

- (RACSignal *)forceUpdate;
- (NSString *)getStringForKey:(NSString *)key;
- (long)getLongForKey:(NSString *)key;
- (BOOL)getBOOLForKey:(NSString *)key;
- (double)getDoubleForKey:(NSString *)key;

@end
