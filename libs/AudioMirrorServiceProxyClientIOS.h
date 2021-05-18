#ifndef _audioMirrorServiceProxyClient_for_IOS_h
#define _audioMirrorServiceProxyClient_for_IOS_h


#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>
#import <dispatch/dispatch.h>


#include <mach/mach_types.h>
#include <libkern/OSAtomic.h>

@protocol AudioMirrorServiceProxyClientDelegate <NSObject>
- (void)audioMirrorServiceConnectionLost:(int)state;
- (void)audioMirrorServiceConnectionCompleted:(int)result;
- (void)audioMirrorServicePeerChanged:(int)peerCount;
- (void)audioMirrorServiceCloseCompleted:(int)result;
- (void)audioMirrorServiceTVAudioOutEnabled:(int)state;
- (void)audioMirrorServiceFound:(char*)serviceJsonString;
//http://stackoverflow.com/questions/29036294/avaudiorecorder-not-recording-in-background-after-audio-session-interruption-end
- (void)audioMirrorServiceAudioDeviceChanged:(int)state; //state: 1 created; 0 destroyed
@end


@interface AudioMirrorServiceProxyClient : NSObject
{
}
@property (assign) id <AudioMirrorServiceProxyClientDelegate> delegate;

- (void)startSearching:(char *)localIPString;
- (void)stopSearching;
- (void)connect:(char *)serverIPString serverPortNumber:(int)portNumber serverConnectionTimeout:(int)connectionTimeout/*in msec*/;
- (void)close;
- (void)enableTVAudioOut:(BOOL)enabled;
- (void)resetStat;
- (NSString*)getStat;
- (int)getAudioBufferingTime;
- (int)getAudioOutLatency;
- (void)setAudioBufferingTime:(int)audioBufferingTime;
- (BOOL)enableAudioOut:(BOOL)enabled;
- (BOOL)hasAudioOutEnabled;
@end


#endif //_audioMirrorServiceProxyClient_for_IOS_h
