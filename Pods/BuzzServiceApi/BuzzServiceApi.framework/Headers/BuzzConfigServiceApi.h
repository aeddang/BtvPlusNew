#import <Foundation/Foundation.h>
@import ReactiveObjC;

#import <BuzzServiceApi/BuzzApiConfig.h>
#import <BuzzServiceApi/BuzzApiGetConfigRequest.h>
#import <BuzzServiceApi/BuzzApiListConfigsRequest.h>
#import <BuzzServiceApi/BuzzApiListConfigsResponse.h>

@protocol BuzzConfigServiceApi <NSObject>

- (RACSignal<BuzzApiListConfigsResponse *> *)getListConfigsWithRequest:(BuzzApiListConfigsRequest *)request;

@end
