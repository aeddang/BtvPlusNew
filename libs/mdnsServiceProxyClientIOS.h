#ifndef _mdnsServiceProxyClientIOS_h
#define _mdnsServiceProxyClientIOS_h


#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>
#import <dispatch/dispatch.h>


#include <mach/mach_types.h>
#include <libkern/OSAtomic.h>

@protocol MDNSServiceProxyClientDelegate <NSObject>
// @protocol MDNSServiceProxyClient <NSObject>
//- (void)mdnsServiceConnectionLost:(int)state;
//- (void)mdnsServiceConnectionCompleted:(int)result;
//- (void)mdnsServicePeerChanged:(int)peerCount;
//- (void)mdnsServiceCloseCompleted:(int)result;
//- (void)mdnsServiceTVAudioOutEnabled:(int)state;
- (void)mdnsServiceFound:(char*)serviceJsonString;
//http://stackoverflow.com/questions/29036294/avaudiorecorder-not-recording-in-background-after-audio-session-interruption-end
//- (void)mdnsServiceAudioDeviceChanged:(int)state; //state: 1 created; 0 destroyed
@end


@interface MDNSServiceProxyClient : NSObject
{
}
@property (assign) id <MDNSServiceProxyClientDelegate> delegate;

- (void)startSearching:(char *)localIPString;
- (void)startClientSearching:(char *)localIPString serviceName:(char *) serviceName querytime:(int)querytimer;
- (void)stopSearching;
- (void)sendCompleteMessage:(char *)targetIPString callno:(char *)callno;
//- (void)connect:(char *)serverIPString serverPortNumber:(int)portNumber serverConnectionTimeout:(int)connectionTimeout/*in msec*/;
//- (void)close;
//- (void)enableTVAudioOut:(BOOL)enabled;
//- (void)resetStat;
//- (NSString*)getStat;
//- (int)getAudioBufferingTime;
//- (int)getAudioOutLatency;
//- (void)setAudioBufferingTime:(int)audioBufferingTime;
//- (BOOL)enableAudioOut:(BOOL)enabled;
//- (BOOL)hasAudioOutEnabled;
@end


#endif //_mdnsServiceProxyClientIOS_h

