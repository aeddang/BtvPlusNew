//
//  NPSUtil.m
//  SKBPairing
//
//  Created by kschang on 2018. 5. 2..
//  Copyright © 2018년 skbroadband. All rights reserved.
//

#import "ApiUtil.h"
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>


@implementation ApiUtil
/**
 * NPS 암호화
 */
+ (NSString *) getEncyptedDataForNps:(NSString *) plainText npsKey:(NSString *)key npsIv:(NSString *)iv
{
    NSData *ivData = [iv dataUsingEncoding:NSUTF8StringEncoding];
    const char * ivChar = [ivData bytes];
    
    NSData *rawkeyData = [key dataUsingEncoding:NSUTF8StringEncoding];
    const char *rawkey = [rawkeyData bytes];
    
    NSData *data = [plainText dataUsingEncoding:NSUTF8StringEncoding];
    NSData *result = [self AES256EncryptWithKey:rawkey theData:data andIv:ivChar];
    NSString *cipherText = [result base64EncodedStringWithOptions:0];
    
    return cipherText;
}

/**
 * NPS 복호화
 */
+ (NSString *) getDecyptedDataForNps:(NSString *)cipherText npsKey:(NSString *)key npsIv:(NSString *)iv
{
    NSData *ivData = [iv dataUsingEncoding:NSUTF8StringEncoding];
    const char *ivChar = [ivData bytes];
    
    NSData *rawkeyData = [key dataUsingEncoding:NSUTF8StringEncoding];
    const char *rawkey = [rawkeyData bytes];
    
    NSData *data = [[NSData alloc] initWithBase64EncodedString:cipherText options:0];
    
    NSData *result = [self AES256DecryptWithKey:rawkey theData:data andIv:ivChar];
    
    NSString *dec = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
    return dec;
}

/**
 * SC 값 암호화
 */
+ (NSString *) getEncrypedSCValue:(NSString *)message nValue:(NSString *)nValue npsPw:(NSString *)pw
{
    NSMutableString *strSC = [[NSMutableString alloc] init];
    [strSC appendString:pw];
    [strSC appendString:message];
    [strSC appendString:nValue];
    
    NSData *data = [self SHAx:strSC];
    NSString *hash = [self hexEncode:data];
    
    return hash;
}

/**
 * HASH ID 반환
 */
+ (NSString *) getHashId:(NSString *)strSTBId
{
    NSString *_pInput = nil;
    if (strSTBId == nil || !([strSTBId length] > 0)) {
        _pInput = @"{00000000-0000-0000-0000-000000000000}";
    } else {
        _pInput = strSTBId;
    }
    NSData *data = [self SHAx:_pInput];
    NSString *hash = [self hexEncode:data];
    
    return hash;
}

/**
 * nValue 값
 */
+ (NSString *) getNValue
{
    int randNum = (arc4random() % 100000000);
    
    NSString *nValue = [NSString stringWithFormat:@"%d", randNum];
    return nValue;
}

+ (NSData *)AES256EncryptWithKey:(const void *)key theData:(NSData *)data andIv:(const void *)iv
{
    NSUInteger dataLength = [data length];
    
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesEncrypted = 0;
    
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding,
                                          key,
                                          kCCKeySizeAES256,
                                          iv,
                                          [data bytes],
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesEncrypted);
    
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    
    free(buffer);
    return nil;
}

+ (NSString *) getAuthVal:(NSString *)timestamp
{
    NSMutableString *auth = [[NSMutableString alloc] init];
    [auth appendString:timestamp];
    NSData* data = [auth dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData *sha256Data = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
    CC_SHA256([data bytes], (CC_LONG)[data length], [sha256Data mutableBytes]);
    return [sha256Data base64EncodedStringWithOptions:0];
}


+ (NSData *)AES256DecryptWithKey:(const void *)key theData:(NSData *)data andIv:(const void *)iv
{
    NSUInteger dataLength = [data length];
    
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesDecrypted = 0;
    
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding,
                                          key,
                                          kCCKeySizeAES256,
                                          iv,
                                          [data bytes],
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesDecrypted);
    
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    free(buffer);
    return nil;
}

+ (NSString *)hexEncode:(NSData *)data
{
    NSMutableString *hex = [NSMutableString string];
    unsigned char *bytes = (unsigned char *)[data bytes];
    char temp[3];
    NSUInteger i=0;
    
    for(i=0; i<[data length]; i++){
        temp[0] = temp[1] = temp[2] =0;
        (void)sprintf(temp, "%02x",bytes[i]);
        [hex appendString:[NSString stringWithUTF8String:temp]];
        
    }
    return hex;
}

+ (NSData *) decodeHexString : (NSString *)hexString
{
    NSInteger tlen = [hexString length]/2;
    
    char tbuf[tlen];
    int i,k,h,l;
    bzero(tbuf, sizeof(tbuf));
    
    for(i=0,k=0;i<tlen;i++)
    {
        h=[hexString characterAtIndex:k++];
        l=[hexString characterAtIndex:k++];
        h=(h >= 'A') ? h-'A'+10 : h-'0';
        l=(l >= 'A') ? l-'A'+10 : l-'0';
        tbuf[i]= ((h<<4)&0xf0)| (l&0x0f);
    }
    
    return [NSData dataWithBytes:tbuf length:tlen];
}

+ (NSData *)SHAx:(NSString *)text
{
    const char *s = [text cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *keyData=[NSData dataWithBytes:s length:strlen(s)];
    
    uint8_t digest[CC_SHA256_DIGEST_LENGTH]={0};
    CC_SHA256(keyData.bytes, (CC_LONG)keyData.length, digest);
    NSData *result = [NSData dataWithBytes:digest length:CC_SHA256_DIGEST_LENGTH];
    
    return result;
}

+ (NSString *)convertMacAddress:(NSString *)macAddr
{
    if (macAddr != nil) {
        NSArray *arrTemp = [[macAddr lowercaseString] componentsSeparatedByString:@":"];
        if ([arrTemp count] == 6) {
            NSMutableString *convertMac = [[NSMutableString alloc] init];
            for (NSString *item in arrTemp) {
                if ([convertMac length] > 0 ) {
                    [convertMac appendString:@":"];
                }
                if ([item length] == 0 ) {
                    [convertMac appendString:@"0"];
                } else if ([item length] > 1) {
                    NSString *first = [item substringWithRange:NSMakeRange(0, 1)];
                    if ([@"0" isEqualToString:first]) {
                        [convertMac appendString:[item substringFromIndex:1]];
                    } else {
                        [convertMac appendString:item];
                    }
                } else {
                    [convertMac appendString:item];
                }
            }
            return convertMac;
        }
    }
    return macAddr;
}

/**
 * for SCS
 */
+ (NSString *) getSCSVerfReqData:(NSString *)stbId plainText:(NSString *)plainText date:(NSDate *)date
{
    //NSString *plainText = @"01012345678";
    
    NSString *key = [self getSCSKey:stbId date:date];
    NSData *rawkeyData = [key dataUsingEncoding:NSUTF8StringEncoding];
    const char *rawkey = [rawkeyData bytes];
    
    NSString *ivStr = [key substringWithRange:NSMakeRange(0, 16)];
    NSData *ivData = [ivStr dataUsingEncoding:NSUTF8StringEncoding];
    const char *iv = [ivData bytes];
    
    NSData *data = [plainText dataUsingEncoding:NSUTF8StringEncoding];
    NSData *encrypted = [self AES256EncryptWithKey:rawkey theData:data andIv:iv];
    if (encrypted) {
        return [self hexEncode:encrypted];
    }
    
    return nil;
}

+ (NSString *) getSCSKey:(NSString *)stbId date:(NSDate *)date
{
    NSMutableString *pKey = [[NSMutableString alloc] init];
    [pKey appendString:@"oEpnlw8nx3"];
    [pKey appendString:[stbId substringWithRange:NSMakeRange(10, 12)]];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MMddHHmmss"];
    [dateFormat setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
    NSString *dateStr =  [dateFormat stringFromDate:date];
    [pKey appendString:dateStr];
    
    return pKey;
}

@end
