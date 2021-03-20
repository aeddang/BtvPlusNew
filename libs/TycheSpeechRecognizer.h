//----------------------------------------------------------------------------
//
//     TTTTTTTT    YY    YY      CCCCC    HH   HH      EEEEEE
//        TT        YY  YY      CC        HH   HH      EE
//        TT         YYYY       CC        HHHHHHH      EEEEE
//        TT          YY        CC        HH   HH      EE
//        TT          YY         CCCCC    HH   HH      EEEEEE
//
//                    SKTelecom, HMI Tech. Lab
//
//----------------------------------------------------------------------------
//	Copyright(c) 2015 SKTelecom All rights reserved.
//
//! @date	July 15, 2016
//! @author
//! @brief	Tyche Speech Recognizer API
//----------------------------------------------------------------------------

#ifdef __OBJC__
#import <Foundation/Foundation.h>
#endif

#ifndef __TYCHE_SPEECHRECOGNIZER_H__
#define __TYCHE_SPEECHRECOGNIZER_H__

@protocol		TriggerListener		<NSObject>
@optional
- (void)		onWakeUp;

- (NSString*)	setStartListeningUxID;
- (NSString*)	setStartListeningOptions;
- (NSString*)	setStartListeningExtOptions;

@required
@end

@protocol		RecognitionListener	<NSObject>
@optional
- (void)		onReady;
- (void)		onSpeechStart;
- (void)		onSpeechEnd;
- (void)		onResult;
- (void)		onRecognitionError
	:(int)error;
- (void)		onCancel;

@required
@end

@interface		SpeechRecognizer	: NSObject

+ (NSString*)	getVersion;

+ (id)			createSpeechRecognizer
	:(NSString*)appType
	:(id<RecognitionListener>)listener;
+ (id)			createSpeechRecognizer
	:(NSString*)appType
	:(id<RecognitionListener>)listener
	:(NSString*)Options;
- (int)			destroy;

- (int)			loadTriggerEngine
	:(int)index;
- (int)			changeTriggerEngine
	:(int)index;

- (int)			startListening
	:(NSString*)uxID
	:(NSString*)Options
	:(NSString*)extOptions;
- (int)			startListening
	:(NSString*)uxID
	:(NSString*)Options;
- (int)			startListening;

- (int)			startBufferListening
	:(NSString*)uxID
	:(NSString*)Options
	:(NSString*)extOptions;
- (int)			startBufferListening
	:(NSString*)uxID
	:(NSString*)Options;

- (int)			stopListening;

- (int)			startListeningWithTrigger
	:(id<TriggerListener>)listener;
- (int)			startListeningWithTrigger;

- (int)			putBuffer
	:(void*)Data
	:(UInt32)ByteSize;

- (int)			cancel;

- (int)			cancelTriggerAndStartListening;

- (int)			saveLog
	:(NSString*)text;

- (int)			getAudioLevel;
- (int)			getSpeechLevel;

- (int)			selectResult
	:(int)idx;

- (int)			checkRecLevel;

- (NSMutableArray*)	getSpeechRecognitionResults;

- (void)		setWaitTime
	:(int)sec;
- (void)		setStartBeep
	:(NSString*)beepfile;
- (void)		setEndBeep
	:(NSString*)beepfile;
- (void)		setEPDLength
	:(int)length;
- (void)		setServerAddr
	:(NSString*)ServerIPAddr
	:(NSString*)ServerPort;

@end

#endif		/* __TYCHE_SPEECHRECOGNIZER_H__ */
