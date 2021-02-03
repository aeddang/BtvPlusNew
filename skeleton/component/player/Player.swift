//
//  Player.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/27.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import AVKit
open class PlayerModel: ComponentObservable {
    static let TIME_SCALE:Double = 600
    @Published var path:String = ""
    @Published var isMute:Bool = false
    @Published var volume:Float = 1.0
    @Published var rate:Float = 1.0
    @Published var screenGravity:AVLayerVideoGravity = .resizeAspectFill
    @Published fileprivate(set) var initTime:Double? = nil
    @Published fileprivate(set) var isPlay = false
    @Published fileprivate(set) var duration:Double = 0.0
    @Published fileprivate(set) var time:Double = 0.0
    @Published var isRunning = false
    @Published var updateType:PlayerUpdateType = .update
    @Published var event:PlayerUIEvent? = nil{
        willSet{
            self.status = .update
        }
        didSet{
            if event == nil { self.status = .ready }
        }
    }
    @Published var remoteEvent:PlayerRemoteEvent? = nil{
        willSet{
            self.status = .update
        }
        didSet{
            if remoteEvent == nil { self.status = .ready }
        }
    }
    
    @Published fileprivate(set) var streamEvent:PlayerStreamEvent? = nil
    @Published fileprivate(set) var playerStatus:PlayerStatus? = nil
    @Published fileprivate(set) var streamStatus:PlayerStreamStatus? = nil
    @Published var playerUiStatus:PlayerUiStatus = .hidden
    @Published var error:PlayerError? = nil
    
    fileprivate var seekTime:Double? = nil
    convenience init(path: String) {
        self.init()
        self.path = path
    }
    
    func reset(){
        isPlay = false
        duration = 0.0
        time = 0.0
        streamEvent = nil
        playerStatus = nil
        streamStatus = nil
        error = nil
    }
    
    func isCompleted() -> Bool{
        if duration == 0.0 {return false}
        return duration == time
    }
    
    
}



enum PlayerUIEvent {//input
    case load(String, Bool = true, Double = 0.0, Dictionary<String,String>? = nil),
         togglePlay, resume, pause, stop, volume(Float), rate(Float), mute(Bool),
         seekTime(Double, Bool = true), seekProgress(Float, Bool = true),
         seekMove(Double, Bool = true),
         seeking(Double), seekForward(Double, Bool = false), seekBackword(Double, Bool = false),
         check, neetLayoutUpdate, screenGravity(AVLayerVideoGravity)
    
    var decription: String {
        switch self {
        case .togglePlay: return "togglePlay"
        case .resume: return "resume"
        case .pause: return "pause"
        case .load: return "load"
        case .stop: return "stop"
        case .volume: return "volume"
        case .seekTime: return "seekTime"
        case .seekProgress: return "seekProgress"
        case .seekMove: return "seekMove"
        default: return ""
        }
    }
}

enum PlayerRemoteEvent {//input
    case next, prev
}

enum PlayerStreamEvent {//output
    case resumed, paused, loaded(String), buffer, stoped, seeked, completed
}

enum PlayerStatus:String {
    case load, resume, pause, seek, complete, error, stop
}

enum PlayerUiStatus:String {
    case view, hidden
}

enum PlayerStreamStatus {
    case buffering(Double), playing, stop
}

enum PlayerError{
    case connect(String), stream(PlayerStreamError), illegalState(PlayerUIEvent)
}
enum PlayerStreamError{
    case playback(String), unknown(String), pip(String), certification(String)
    func getDescription() -> String {
        switch self {
        case .pip(let s):
            return "PlayerStreamError pip " + s
        case .playback(let s):
            return "PlayerStreamError playback " + s
        case .certification(let s):
            return "PlayerStreamError certification " + s
        case .unknown(let s):
            return "PlayerStreamError unknown " + s
        }
    }
}

enum PlayerUpdateType{
    case initate, update, recovery(Double)
}

protocol PlayBack:PageProtocol {
    var viewModel:PlayerModel {get set}
    func onTimeChange(_ t:Double)
    func onDurationChange(_ t:Double)
    func onLoad()
    func onLoaded()
    func onSeek(time:Double)
    func onSeeked()
    func onResumed()
    func onPaused()
    func onReadyToPlay()
    func onBuffering(rate:Double)
    func onBufferCompleted()
    func onStoped()
    func onCompleted()
    func onError(_ error:PlayerStreamError)
}

extension PlayBack {
    func onTimeChange(_ t:Double){
        viewModel.time = t
        if let checkTime = viewModel.seekTime {
            if abs(checkTime-t) <= 1 {
                self.checkSeeked()
            }
        }
    }
    func onDurationChange(_ t:Double){
        if t <= 0 { return }
        viewModel.duration = t
        viewModel.updateType = .update
    }
    func onLoad(){
        ComponentLog.d("onLoad", tag: self.tag)
        viewModel.playerStatus = .load
        viewModel.updateType = .initate
        
    }
    func onLoaded(){
        ComponentLog.d("onLoaded", tag: self.tag)
        viewModel.streamEvent = .loaded(viewModel.path)
    }
    func onSeek(time:Double){
        if viewModel.playerStatus == .error {
            ComponentLog.d("error reload", tag: self.tag)
            return
        }
        ComponentLog.d("onSeek", tag: self.tag)
        viewModel.seekTime = time
        viewModel.playerStatus = .seek
        //onBuffering()
    }
    func checkSeeked(){
        switch self.viewModel.playerStatus {
        case .seek: onSeeked()
        default: break
        }
    }
    
    func onSeeked(){
        ComponentLog.d("onSeeked", tag: self.tag)
        viewModel.seekTime = nil
        viewModel.streamEvent = .seeked
    }
    func onResumed(){
        self.checkSeeked()
        ComponentLog.d("onResumed", tag: self.tag)
        viewModel.isPlay = true
        viewModel.streamEvent = .resumed
        viewModel.playerStatus = .resume
        onBufferCompleted()
    }
    func onPaused(){
        self.checkSeeked()
        viewModel.isPlay = false
        if viewModel.playerStatus == .complete
            || viewModel.playerStatus == .error {
            ComponentLog.d("already paused", tag: self.tag)
            return
        }
        ComponentLog.d("onPaused", tag: self.tag)
        viewModel.streamEvent = .paused
        viewModel.playerStatus = .pause
        onBufferCompleted()
    }
    func onReadyToPlay(){
        ComponentLog.d("onReadyToPlay", tag: self.tag)
        onBufferCompleted()
        switch self.viewModel.playerStatus {
        case .load: onLoaded()
        case .seek: onSeeked()
        default: break
        }
    }
    
    func onBuffering(rate:Double = 0){
        ComponentLog.d("onBuffering", tag: self.tag)
        viewModel.streamEvent = .buffer
        viewModel.streamStatus = .buffering(rate)
    }
    
    func onBufferCompleted(){
        self.checkSeeked()
        ComponentLog.d("onBufferCompleted", tag: self.tag)
        viewModel.streamStatus = .playing
    }
    
    func onStoped(){
        if viewModel.playerStatus == .error {
            ComponentLog.d("already stoped", tag: self.tag)
            return
        }
        ComponentLog.d("onStoped", tag: self.tag)
        viewModel.streamEvent = .stoped
        viewModel.playerStatus = .stop
        viewModel.streamStatus = .stop
    }
    
    func onCompleted(){
        ComponentLog.d("onCompleted", tag: self.tag)
        viewModel.streamEvent = .completed
        viewModel.playerStatus = .complete
    }
    
    func onError(_ error:PlayerStreamError){
        ComponentLog.e("onError" + error.getDescription(), tag: self.tag)
        viewModel.error = .stream(error)
        viewModel.streamEvent = .stoped
        viewModel.streamStatus = .stop
        viewModel.playerStatus = .error
        viewModel.updateType = .recovery(viewModel.time)
    }
}
