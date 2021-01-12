//
//  NPSUtil.h
//  SKBPairing
//
//  Created by kschang on 2018. 5. 2..
//  Copyright © 2018년 skbroadband. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ApiUtil : NSObject

/**
 * NPS 암호화
 */
+ (NSString *) getEncyptedDataForNps:(NSString *) plainText npsKey:(NSString *)key npsIv:(NSString *)iv;

/**
 * NPS 복호화
 */
+ (NSString *) getDecyptedDataForNps:(NSString *) cipherText npsKey:(NSString *)key npsIv:(NSString *)iv;

/**
 * SC 값 암호화
 */
+ (NSString *) getEncrypedSCValue:(NSString *)message nValue:(NSString *)nValue npsPw:(NSString *)pw;

/**
 * nValue 값
 */
+ (NSString *) getNValue;

@end
