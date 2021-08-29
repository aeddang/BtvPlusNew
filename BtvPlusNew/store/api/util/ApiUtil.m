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
#include <ifaddrs.h>
#include <arpa/inet.h>
#include <net/if.h>
#import "BtvPlusNew-Swift.h"

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



+ (NSString *)getCBSEncrypted:(NSString *)_input uuid:(NSString *)_uuid
{
    // 2) UUID →  SHA256 적용
    NSString *sha256UUID= [ApiUtil getSHA256:_uuid];
    
    // 3) 암호화 KEY와 IV 추출
    NSString *keyStr = [sha256UUID substringWithRange:NSMakeRange(0, 32)];
    NSString *ivLast = [sha256UUID substringWithRange:NSMakeRange((sha256UUID.length - 10), 10)];
    NSString *ivStr = [NSString stringWithFormat:@"BWORLD%@", ivLast];
    
    // 4) 추출된 KEY와 IV로 문자열 AES암호화 적용 (BASE64 Encoding 포함)

    NSString *cipherText = [CryptoUtil aes256WithPlain:_input key:keyStr iv:ivStr]; 
//    NSData *ivData = [ivStr dataUsingEncoding:NSUTF8StringEncoding];
//    const char *iv = [ivData bytes];
//    NSData *rawkeyData = [keyStr dataUsingEncoding:NSUTF8StringEncoding];
//    const char *rawkey = [rawkeyData bytes];
//    NSData *data = [_input dataUsingEncoding:NSUTF8StringEncoding];
//    NSData *result = [self AES256EncryptWithKey:rawkey theData:data andIv:iv];
//    NSString *cipherText = [result base64EncodedStringWithOptions:0];
    
    // 5) equal 문자 제거
    NSString *removeEqual = [cipherText stringByReplacingOccurrencesOfString:@"=" withString:@""];
    
    // 6) URL Encoding 적용
    NSString *urlEncoded = [ApiUtil stringByUrlEncoding:removeEqual];
    
    return urlEncoded;
}

+ (NSString *)getSHA256:(NSString *)_input
{
    NSData *data = [self SHAx:_input];
    NSString *result = [self hexEncode:data];
    
    return result;
}

+ (NSString *) stringByUrlEncoding:(NSString *)_str
{
    if (_str && [_str length]>0) {
        return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                     kCFAllocatorDefault,
                                                                                     (CFStringRef)_str,
                                                                                     NULL,
                                                                                     CFSTR(":/?#[]@!$&'()*+,;="),
                                                                                     kCFStringEncodingUTF8));
    }
    return @"";
}


#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IOS_VPN         @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"

+ (NSString *)getIPAddress:(BOOL)preferIPv4 {
    NSArray *searchArray = preferIPv4 ?
    @[ IOS_VPN @"/" IP_ADDR_IPv4, IOS_VPN @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6 ] :
    @[ IOS_VPN @"/" IP_ADDR_IPv6, IOS_VPN @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4 ] ;
    
    NSDictionary *addresses = [self getIPAddresses];
    NSLog(@"addresses: %@", addresses);
    
    __block NSString *address;
    [searchArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
        address = addresses[key];
        //筛选出IP地址格式
        if([self isValidatIP:address]) *stop = YES;
    } ];
    return address ? address : @"0.0.0.0";
}

+ (BOOL)isValidatIP:(NSString *)ipAddress {
    if (ipAddress.length == 0) {
        return NO;
    }
    NSString *urlRegEx = @"^([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])$";
    
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:urlRegEx options:0 error:&error];
    
    if (regex != nil) {
        NSTextCheckingResult *firstMatch=[regex firstMatchInString:ipAddress options:0 range:NSMakeRange(0, [ipAddress length])];
        
        if (firstMatch) {
            NSRange resultRange = [firstMatch rangeAtIndex:0];
            NSString *result=[ipAddress substringWithRange:resultRange];
            //输出结果
            NSLog(@"ESPTools 输出结果：%@",result);
            return YES;
        }
    }
    return NO;
}

+ (NSDictionary *)getIPAddresses
{
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
    
    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for(interface=interfaces; interface; interface=interface->ifa_next) {
            if(!(interface->ifa_flags & IFF_UP) /* || (interface->ifa_flags & IFF_LOOPBACK) */ ) {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                NSString *type;
                if(addr->sin_family == AF_INET) {
                    if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv4;
                    }
                } else {
                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
                    if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv6;
                    }
                }
                if(type) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    return [addresses count] ? addresses : nil;
}



@end
