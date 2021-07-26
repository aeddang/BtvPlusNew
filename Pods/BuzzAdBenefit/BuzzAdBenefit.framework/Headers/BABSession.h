//
//  BABSession.h
//  BAB
//
//  Created by Jaehee Ko on 18/12/2018.
//  Copyright © 2018 Buzzvil. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BABSession : NSObject

@property (nonatomic, copy, readonly) NSString *sessionKey;
@property (nonatomic, copy, readonly) NSString *deviceId;

- (instancetype)initWithDictionary:(NSDictionary *)dic;
- (NSDictionary *)toDictionary;

@end

NS_ASSUME_NONNULL_END
