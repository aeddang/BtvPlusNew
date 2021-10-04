//
//  Player.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/27.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import AVKit
import Combine
open class PlayerModel: ComponentObservable {
    static let TIME_SCALE:Double = 600
    var useAvPlayerController:Bool = false
    var useFullScreenButton:Bool = true
    var useFullScreenAction:Bool = true
    var useRecovery:Bool = false
    var drm:FairPlayDrm? = nil
    var header:[String:String]? = nil
    @Published var path:String = ""
    var recoveryPath:String? = nil
    @Published var isMute:Bool = false
    @Published var isLock:Bool = false
    @Published var volume:Float = -1
    @Published var bitrate:Double? = nil
    @Published var screenRatio:CGFloat = 1.0
    @Published var seeking:Double = 0
    @Published var rate:Float = 1.0
    @Published var playInfo:String? = nil
    @Published var assetInfo:AssetPlayerInfo? = nil
    
    @Published var screenGravity:AVLayerVideoGravity = .resizeAspect
    @Published fileprivate(set) var initTime:Double? = nil
    @Published fileprivate(set) var isPlay = false
    var isUserPlay = false
    var isSeekAfterPlay:Bool? = nil
    
    @Published fileprivate(set) var duration:Double = 0.0
    fileprivate(set) var originDuration:Double = 0
    fileprivate(set) var recoveryCount:Int = 0
    fileprivate(set) var toMinimizeStallsCount:Int = 0
    open var limitedDuration:Double? = nil
    
    @Published fileprivate(set) var time:Double = 0.0
    @Published var isRunning = false
    @Published var isReplay = false
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
    convenience init(useFullScreenAction: Bool, useFullScreenButton: Bool = true, useRecovery:Bool = false) {
        self.init()
        self.useRecovery = useRecovery
        self.useFullScreenButton = useFullScreenButton
        self.useFullScreenAction = useFullScreenAction
    }
    
    open func reset(){
        time = 0
        recoveryPath = nil
        limitedDuration = nil
        screenRatio = 1.0
        playInfo = nil
        header = nil
        path = ""
        drm = nil
        reload()
    }
    
    open func reload(){
        isPlay = false
        duration = 0
        originDuration = 0
        time = 0
        streamEvent = nil
        playerStatus = nil
        streamStatus = nil
        error = nil
    }
    
    open func isCompleted() -> Bool{
        if duration == 0.0 {return false}
        return duration == time
    }
    
    func getSeekForwardAmount(t:Double = 10)->Double {
        self.delayAutoResetSeekMove()
        self.seekMove = self.seekMove < 0 ? self.seekMove - t : -t
        return -self.seekMove
    }
    
    func getSeekBackwordAmount(t:Double = 10)->Double {
        self.delayAutoResetSeekMove()
        self.seekMove = self.seekMove > 0 ? self.seekMove + t : t
        return self.seekMove
    }
    
    private(set)var seekMove:Double = 0
    private var autoResetSeekMove:AnyCancellable?
    private func delayAutoResetSeekMove(){
        self.autoResetSeekMove?.cancel()
        self.autoResetSeekMove = Timer.publish(
            every: 1.0, on: .current, in: .common)
            .autoconnect()
            .sink() {_ in
                self.autoResetSeekMove?.cancel()
                self.seekMove = 0
            }
    }
}
class FairPlayDrm{
    
    let ckcURL:String
    let certificateURL:String
    var contentId:String? = nil
    var certificate:Data? = nil
 
    var isCompleted:Bool = false
    init( ckcURL:String,
          certificateURL:String) {
        
        self.ckcURL = ckcURL
        self.certificateURL = certificateURL
            
    }
}

enum PlayerUIEvent {//input
    case load(String, Bool = true, Double = 0.0, Dictionary<String,String>? = nil),
         togglePlay(isUser:Bool = false),
         resume(isUser:Bool = false), pause(isUser:Bool = false), stop(isUser:Bool = false),
         volume(Float, isUser:Bool),  rate(Float,isUser:Bool), mute(Bool, isUser:Bool),
         seekTime(Double, Bool? = nil, isUser:Bool), seekProgress(Float, Bool? = nil, isUser:Bool),
         seekMove(Double, Bool? = nil, isUser:Bool),
         seeking(Double, isUser:Bool),
         seekForward(Double, Bool? = nil, isUser:Bool), seekBackword(Double, Bool? = nil, isUser:Bool),
         addSeekForward(Double, Bool? = nil, isUser:Bool), addSeekBackword(Double, Bool? = nil, isUser:Bool),
         check, neetLayoutUpdate, fixUiStatus(Bool),
         screenGravity(AVLayerVideoGravity), screenRatio(CGFloat),
         fullScreen(Bool),
         replay(Bool),
         recovery(isUser:Bool = false)
            
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
    case resumed, paused, loaded(String), buffer, stoped, seeked, completed, recovery
}

enum PlayerStatus:String {
    case load, resume, pause, seek, complete, error, stop
}

enum PlayerUiStatus:String {
    case view, hidden
}

enum PlayerStreamStatus :Equatable{
    case buffering(Double), playing, stop
    
    public static func == (l:PlayerStreamStatus, r:PlayerStreamStatus)-> Bool {
        switch (l, r) {
        case ( .buffering, .buffering):return true
        case ( .playing, .playing):return true
        case ( .stop, .stop):return true
        default: return false
        }
    }
}

enum PlayerError{
    case connect(String), stream(PlayerStreamError), illegalState(PlayerUIEvent), drm(DRMError), asset(AssetLoadError)
}
enum PlayerStreamError:Error{
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
    case initate, update, recovery(Double, count:Int = -1)
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
    func onToMinimizeStalls()
    func onBuffering(rate:Double)
    func onBufferCompleted()
    func onStoped()
    func onCompleted()
    func onError(_ error:PlayerStreamError)
    func onError(playerError:PlayerError)
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
        viewModel.originDuration = t
        if let limit = viewModel.limitedDuration {
            viewModel.duration = min(t, limit)
        }else{
            viewModel.duration = t
        }
        viewModel.updateType = .update
    }
    func onLoad(){
        ComponentLog.d("onLoad", tag: self.tag)
        self.checkSeeked()
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
        ComponentLog.d("onSeeked " + viewModel.isPlay.description, tag: self.tag)
        viewModel.seekTime = nil
        viewModel.streamEvent = .seeked
        viewModel.event = .check
        viewModel.playerStatus = viewModel.isPlay ? .resume : .pause
        if let afterPlay = viewModel.isSeekAfterPlay {
            DispatchQueue.main.async {
                viewModel.event = afterPlay ? .resume(): .pause()
                viewModel.isSeekAfterPlay = nil
            }
        }
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
        if self.viewModel.toMinimizeStallsCount > 1 {
            onError(.playback("toMinimizeStalls"))
            onBufferCompleted()
        } else {
            onBufferCompleted()
        }
    }
    func onReadyToPlay(){
        ComponentLog.d("onReadyToPlay", tag: self.tag)
        self.viewModel.recoveryCount = 0
        onBufferCompleted()
        switch self.viewModel.playerStatus {
        case .load: onLoaded()
        case .seek: onSeeked()
        default: break
        }
    }
    func onToMinimizeStalls(){
        self.viewModel.toMinimizeStallsCount += 1
        onBuffering(rate:0)
        ComponentLog.d("onToMinimizeStalls " + self.viewModel.toMinimizeStallsCount.description, tag: self.tag)
    }
    func onBuffering(rate:Double = 0){
        ComponentLog.d("onBuffering", tag: self.tag)
        viewModel.streamEvent = .buffer
        viewModel.streamStatus = .buffering(rate)
    }
    
    func onBufferCompleted(){
        self.checkSeeked()
        ComponentLog.d("onBufferCompleted", tag: self.tag)
        viewModel.toMinimizeStallsCount = 0
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
        if self.viewModel.useRecovery {
            viewModel.streamEvent = .recovery
            self.viewModel.recoveryCount += 1
        }
    }
    
    func onError(playerError:PlayerError){
        DispatchQueue.main.async {
            viewModel.error = playerError
            viewModel.streamEvent = .stoped
            viewModel.streamStatus = .stop
            viewModel.playerStatus = .error
        }
        
    }
}
