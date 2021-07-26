//
//  BABDeviceInfo.h
//  BAB
//
//  Created by Jaehee Ko on 02/07/2019.
//  Copyright © 2019 Buzzvil. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BABDeviceInfo : NSObject

- (NSString *)modelIdentifier;
- (NSString *)osVersion;
- (NSString *)screenResolution;
- (NSString *)networkType;
- (NSString *)userAgent;
- (NSString *)language;
- (NSString *)locale;
- (NSString *)timezone;
- (NSString *)carrier;
- (NSString *)mccMnc;

- (NSDictionary *)toDictionary;
@end

NS_ASSUME_NONNULL_END
