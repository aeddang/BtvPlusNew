#import <Foundation/Foundation.h>
#import <ReactiveObjC/ReactiveObjC.h>

@protocol BuzzScreenServiceApi <NSObject>

- (RACSignal<NSDictionary *> *)initializeSdkWithUnitId:(NSString *)unitid;

@end
