//
//  VoiceRecognition.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/03/19.
//

import Foundation
import AVFoundation


class VoiceRecognition:  NSObject, ObservableObject, RecognitionListener , PageProtocol{
    private var appSceneObserver:AppSceneObserver? = nil
    var recognizer: SpeechRecognizer? = nil
    
    @Published private(set) var event:VoiceEvent? = nil {didSet{ if event != nil { event = nil} }}
    @Published private(set) var status:VoiceStatus = .initate

    init(appSceneObserver:AppSceneObserver? = nil) {
        self.appSceneObserver = appSceneObserver
    }
    
    
    
    func start(){
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            ComponentLog.d("requestRecordPermission " + granted.description, tag: self.tag)
            if !granted {
                ComponentLog.d("onStart fail", tag: self.tag)
                DispatchQueue.main.async {
                    self.appSceneObserver?.alert = .alert(nil, String.alert.needMicPermission){
                        self.event = .permissionError
                    }
                }
                return
            } else {
                DispatchQueue.main.async { self.onStart() }
            }
        }
        
    }
    private func onStart(){
        self.initAVAudioSession()
        self.initRecognizer()
        self.status = .ready
        ComponentLog.d("onStart " + self.status.rawValue, tag: self.tag)
    }
    func stop(){
        self.recognizer?.stopListening()
        self.destroyAVAudioSession()
        self.destroyRecognizer()
        self.status = .initate
        ComponentLog.d("onStop", tag: self.tag)
    }
    
    @discardableResult
    func search() -> Bool{
        //ComponentLog.d("search " + self.status.rawValue, tag: self.tag)
        //if self.status != .ready {return false}
        self.recognizer?.startListening()
        return true
    }
    
    private func onError(){
        self.stop()
        self.event = .error
    }
    
    // MARK: - listener
    func onReady() {
        ComponentLog.d("onReady", tag: self.tag)
        self.status = .ready
        
    }
    func onSpeechStart() {
        ComponentLog.d("onSpeechStart", tag: self.tag)
        self.status = .searching
        
    }
    func onSpeechEnd() {
        ComponentLog.d("onSpeechEnd", tag: self.tag)
        self.status = .analysis
    }
    func onResult() {
        ComponentLog.d("onResult", tag: self.tag)
        if let results = self.recognizer?.getSpeechRecognitionResults(),
           let result = results.firstObject as? String,
           !result.isEmpty {
                ComponentLog.d("onResult find " + result, tag: self.tag)
                self.event = .find(result)
        } else {
            ComponentLog.d("onResult none", tag: self.tag)
        }
        //self.status = .ready
    }
    func onRecognitionError(_ error: Int32) {
        self.event = .error
        ComponentLog.e("onRecognitionError " + error.description, tag: self.tag)
        switch error {
        case -10000:
            self.onError()
        case -10002 ... -10001:
            break
        default:
            self.onError()
            return
        }
        //self.status = .ready
    }
    func onCancel() {
        if self.status == .initate {return}
        self.status = .ready
    }
    
    private func initAVAudioSession() {
       
        NotificationCenter.default.addObserver(self, selector: #selector(audioSessionInterrupted), name: AVAudioSession.interruptionNotification, object: nil)
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.playAndRecord)
            try audioSession.setActive(true)
            ComponentLog.d("initAVAudioSession", tag: self.tag)
            
        } catch let error as NSError {
            ComponentLog.e("audioSession init error: \(error.localizedDescription)", tag: self.tag)
            self.onError()
        }
    }
    
    @objc func audioSessionInterrupted(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
            let interruptionTypeRawValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
            let interruptionType = AVAudioSession.InterruptionType(rawValue: interruptionTypeRawValue) else {
                return
        }
        ComponentLog.e("interruptionType: \(interruptionType)", tag: self.tag)
        switch interruptionType {
        case .began:
            self.event = .error
        case .ended:
            break
        @unknown default:
            break
        }
    }
    
    private func destroyAVAudioSession() {
        ComponentLog.d("destroy AVAudioSession", tag: self.tag)
        NotificationCenter.default.removeObserver(self)
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.playAndRecord)
            try audioSession.setActive(false)
            
        } catch let error as NSError {
            ComponentLog.e("audioSession destroy error: \(error.localizedDescription)", tag: self.tag)
        }
    }
    
    private func initRecognizer() {
        if let recognizer = SpeechRecognizer.createSpeechRecognizer("STB_SKB", self, nil) as? SpeechRecognizer {
            self.recognizer = recognizer
            ComponentLog.e("recognizer init", tag: self.tag)
        } else {
            ComponentLog.e("recognizer init error", tag: self.tag)
            self.onError()
        }
    }
    private func destroyRecognizer() {
        ComponentLog.d("destroy Recognizer", tag: self.tag)
        self.recognizer?.destroy()
        self.recognizer = nil
    }
}
