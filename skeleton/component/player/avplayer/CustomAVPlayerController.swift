//
//  CustomCamera.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/22.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import AVKit
import MediaPlayer

extension CustomAVPlayerController: UIViewControllerRepresentable, PlayBack, PlayerScreenViewDelegate {
    fileprivate(set) static var currentPlayer:[String] = []
    fileprivate(set) static var currentPlayerNum:Int  = 0
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<CustomAVPlayerController>) -> UIViewController {
        let playerScreenView = PlayerScreenView(frame: .infinite)
        playerScreenView.mute(self.viewModel.isMute)
        playerScreenView.currentRate = self.viewModel.rate
        playerScreenView.currentVideoGravity = self.viewModel.screenGravity
        playerScreenView.currentRatio = self.viewModel.screenRatio
        
        if self.viewModel.useAvPlayerController {
            let playerController = CustomAVPlayerViewController(viewModel: self.viewModel, playerScreenView: playerScreenView)
            playerController.delegate = context.coordinator
            playerScreenView.delegate = self
            playerScreenView.playerController = playerController
            
            return playerController
        }else{
            let playerController = CustomPlayerViewController(viewModel: self.viewModel, playerScreenView: playerScreenView)
            playerScreenView.delegate = self
            
            playerScreenView.playerLayer = AVPlayerLayer()
            playerController.view = playerScreenView
            return playerController
        }
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<CustomAVPlayerController>) {
        //ComponentLog.d("updateUIView status " + viewModel.id , tag: self.tag)
        if viewModel.status != .update { return }
        guard let evt = viewModel.event else { return }
        guard let player = (uiViewController as? CustomPlayerController)?.playerScreenView else { return }
        if let e = player.player?.error {
            ComponentLog.d("updateUIView error " + e.localizedDescription , tag: self.tag)
        }
        switch viewModel.updateType {
        case .recovery(let t, let count):
             ComponentLog.d("recovery" , tag: self.tag)
             recovery(player, evt: evt, recoveryTime: t, retryCount: count)
        case .initate :
             ComponentLog.d("initate" , tag: self.tag)
             recovery(player, evt: evt, recoveryTime: 0)
        default:
             update(player, evt: evt)
        }
    }
    
    private func recovery(_ player: PlayerScreenView, evt:PlayerUIEvent, recoveryTime:Double, retryCount:Int = -1){
        viewModel.updateType = .update
        var initTime = recoveryTime
        var isPlay = true
        switch evt {
        case .togglePlay: break
        case .resume: break
        case .seekTime(let t, let play):
            initTime = t
            isPlay = play ?? true
        case .seekProgress(let pct, let play):
            let t = viewModel.duration * Double(pct)
            isPlay = play ?? true
            initTime = t
        default :
            self.update(player, evt: evt)
            return
        }
       
        let path = retryCount > 1 ? viewModel.recoveryPath ?? viewModel.path : viewModel.path
        ComponentLog.d("recovery " + path , tag: self.tag)
        viewModel.event = .load(path, isPlay , initTime, viewModel.header)
    }
    
    private func update(_ player:PlayerScreenView, evt:PlayerUIEvent){
        //ComponentLog.d("update evt" , tag: self.tag)
        DispatchQueue.main.async {
            self.updateExcute(player, evt:evt)
        }
        viewModel.event = nil
    }
    
    
    private func updateExcute(_ player:PlayerScreenView, evt:PlayerUIEvent) {
        switch evt {
        case .load(let path, let isAutoPlay, let initTime, let header):
            viewModel.reload()
            if path == "" {viewModel.error = .connect(path)}
            viewModel.path = path
            self.onLoad()
            player.mute(viewModel.isMute)
            player.load(path, isAutoPlay: isAutoPlay, initTime: initTime, header:header, assetInfo: self.viewModel.assetInfo, drmData: viewModel.drm)
            run(player)
        case .check:
            if self.viewModel.isRunning {return}
            run(player)
        case .togglePlay:
            if self.viewModel.isPlay {  onPause() } else { onResume() }
        case .resume: onResume()
        case .pause: onPause()
        case .stop:
            player.stop()
            self.onStoped()
        case .volume(let v):
            MPVolumeView.setVolume(v)
            viewModel.volume = v
            if v == 0{
                viewModel.isMute = true
                player.mute(true)
            }else if viewModel.isMute {
                viewModel.isMute = false
                player.mute(false)
            }
            
        case .mute(let isMute):
            viewModel.isMute = isMute
            player.mute(isMute)
        case .screenRatio(let r):
            player.currentRatio = r
            viewModel.screenRatio = r
            
        case .rate(let r):
            player.currentRate = r
            viewModel.rate = r
            
        case .screenGravity(let gravity):
            viewModel.screenGravity = gravity
            viewModel.screenRatio = 1
            player.currentVideoGravity = gravity
            player.currentRatio = 1
           
            
        case .seekTime(let t, let play): onSeek(time:t, play: play)
        case .seekMove(let t, let play): onSeek(time:viewModel.time + t, play: play)
        case .seekForward(let t, let play): onSeek(time:viewModel.time + t , play: play)
        case .seekBackword(let t, let play): onSeek(time:viewModel.time - t , play: play)
        case .seekProgress(let pct, let play):
            let t = viewModel.duration * Double(pct)
            onSeek(time:t, play: play)
        case .neetLayoutUpdate :
            player.setNeedsLayout()
        default : break
        }
        
        func onResume(){
            if viewModel.playerStatus == .complete {
                onSeek(time: 0, play:true)
                return
            }
            if !player.resume() {
                viewModel.error = .illegalState(evt)
                return
            }
            run(player)
        }
        func onPause(){
            if !player.pause() { viewModel.error = .illegalState(evt) }
        }
        
        func onSeek(time:Double, play:Bool?){
            var st = min(time, (self.viewModel.limitedDuration ?? self.viewModel.duration) - 5 )
            st = max(st, 0)
            viewModel.isSeekAfterPlay = play
            if !player.seek(st) { viewModel.error = .illegalState(evt) }
            self.onSeek(time: st)
            if self.viewModel.isRunning {return}
            //if play { onResume() }
            run(player)
        }
    }
        
    private func run(_ player: PlayerScreenView){
        var job:AnyCancellable? = nil
        var timeControlStatus:AVPlayer.TimeControlStatus? = nil
        var status:AVPlayer.Status? = nil
        var isCheckStatus:Bool = false
        var isCheckTimeControlStatus:Bool = false
        viewModel.isRunning = true
        
        
        job = Timer.publish(every: 1, on:.current, in: .common)
            .autoconnect()
            .sink{_ in
                guard let currentPlayer = player.player else {
                    self.cancel(job, reason: "destory plyer")
                    self.onStoped()
                    return
                }
                let t = CMTimeGetSeconds(currentPlayer.currentTime())
                let d = viewModel.duration
                if d > 0 {
                    
                    if viewModel.isReplay && t >= (d - 1) {
                        self.viewModel.event = .seekTime(0, true)
                    }
                    if t >= d {
                        if viewModel.playerStatus != .seek && viewModel.playerStatus != .pause {
                            self.cancel(job, reason: "duration completed")
                            player.pause()
                            self.onTimeChange(viewModel.duration)
                            self.onPaused()
                            self.onCompleted()
                            return
                        }
                    }
                }
                //ComponentLog.d("Timer " + t.description , tag: self.tag)
                self.onTimeChange(Double(t))
                //player.layer.setNeedsDisplay()
                if !isCheckTimeControlStatus {
                    DispatchQueue.global(qos: .background).async {
                        //ComponentLog.d("isCheckTimeControlStatus" , tag: self.tag)
                        if currentPlayer.timeControlStatus != timeControlStatus {
                            switch currentPlayer.timeControlStatus{
                            case .paused:
                                DispatchQueue.main.async {
                                    self.cancel(job, reason: "pause")
                                    self.onPaused()
                                }
            
                            case .playing:
                                DispatchQueue.main.async {
                                    self.onResumed()
                                }
                            case .waitingToPlayAtSpecifiedRate:
                                switch currentPlayer.reasonForWaitingToPlay {
                                case .some(let reason):
                                    switch reason {
                                    case .evaluatingBufferingRate:
                                        DispatchQueue.main.async {self.onBuffering(rate: 0.0)}
                                    case .noItemToPlay:  DispatchQueue.main.async {self.cancel(job, reason: "noItemToPlay")}
                                    case .toMinimizeStalls:
                                        DispatchQueue.main.async {self.onBuffering(rate: 0.0)}
                                    default:break
                                    }
                                default:break
                                }
                            default:break
                            }
                            timeControlStatus = currentPlayer.timeControlStatus
                            isCheckTimeControlStatus = false
                        }
                    }
                }
                if !isCheckStatus {
                    DispatchQueue.global(qos: .background).async {
                        //ComponentLog.d("isCheckStatus" , tag: self.tag)
                        if(status != currentPlayer.status){
                            isCheckStatus = true
                            switch currentPlayer.status {
                            case .failed:
                                DispatchQueue.main.async {
                                    self.cancel(job, reason: "failed")
                                    self.onPlayerError(.playback("failed"))
                                }
                            case .unknown:break
                            case .readyToPlay:
                                if let d = currentPlayer.currentItem?.asset.duration {
                                    let willDuration = Double(CMTimeGetSeconds(d))
                                    if willDuration != viewModel.originDuration {
                                        DispatchQueue.main.async {
                                            self.onDurationChange(willDuration)
                                            player.playInit(duration: willDuration)
                                        }
                                       
                                    }
                                }
                                
                                DispatchQueue.main.async {
                                    self.onReadyToPlay()
                                }
                        
                            @unknown default:break
                            }
                            status = currentPlayer.status
                            isCheckStatus = false
                        }
                    }
                }
        }
    }
    
    private func cancel(_ job:AnyCancellable?, reason:String? = nil){
        viewModel.isRunning = false
        if let msg = reason {
            ComponentLog.d("cancel reason " + msg , tag: self.tag)
        }
        job?.cancel()
    }
    
    func onPlayerAssetInfo(_ info:AssetPlayerInfo) {
        DispatchQueue.main.async {
            self.viewModel.assetInfo = info
        }
    }
    
    func onPlayerCompleted(){
        self.onCompleted()
    }

    func onPlayerError(_ error:PlayerStreamError){
        self.onError(error)
    }
    
    func onPlayerError(playerError:PlayerError){
        self.onError(playerError:playerError)
    }

    func onPlayerBecomeActive(){
        self.viewModel.event = .check
    }
    func onPlayerVolumeChanged(_ v:Float){
        if self.viewModel.volume == -1 {
            self.viewModel.volume = v
            return
        }
        if self.viewModel.volume == v {return}
        self.viewModel.volume = v
        if viewModel.isMute {
            self.viewModel.event = .volume(v)
        }
    }
    func onPlayerBitrateChanged(_ bitrate: Double) {
        self.viewModel.bitrate = bitrate
    }
}

extension MPVolumeView {
    static func moveVolume(_ move: Float) -> Void {
        let volumeView = MPVolumeView(frame: .zero)
        let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider
       
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {
            guard let prev = slider else {return}
            let preV = convertVolume(prev.value)
            DataLog.d("preV " + preV.description, tag:"MPVolumeView")
            DataLog.d("move " + move.description, tag:"MPVolumeView")
            let v = preV + move
            prev.value = v
           
        }
        func convertVolume(_ value: Float) -> Float {
            if value == 0.0 {
                return 0.0
            }
            let convertValue: Int = Int((value * 10))
            return Float(convertValue) * 0.1
        }
    }
    static func setVolume(_ volume: Float) -> Void {
        let volumeView = MPVolumeView(frame: .zero)
        let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {
            slider?.value = volume
            
        }
        
    }
}

struct CustomAVPlayerController {
    @ObservedObject var viewModel:PlayerModel
    @ObservedObject var pageObservable:PageObservable
    func makeCoordinator() -> Coordinator { return Coordinator(viewModel:self.viewModel) }
    
    class Coordinator:NSObject, AVPlayerViewControllerDelegate, PageProtocol {
        var viewModel:PlayerModel
        init(viewModel:PlayerModel){
            self.viewModel = viewModel
        }
        func playerViewController(_ playerViewController: AVPlayerViewController, willBeginFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator){
        }
        func playerViewController(_ playerViewController: AVPlayerViewController, willEndFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator){
        }

        func playerViewControllerWillStartPictureInPicture(_ playerViewController: AVPlayerViewController){
            ComponentLog.d("playerViewControllerWillStartPictureInPicture" , tag: self.tag)
        }

        func playerViewControllerDidStartPictureInPicture(_ playerViewController: AVPlayerViewController){
            ComponentLog.d("playerViewControllerDidStartPictureInPicture" , tag: self.tag)
        }
        
        func playerViewController(_ playerViewController: AVPlayerViewController, failedToStartPictureInPictureWithError error: Error){
            self.viewModel.error = .stream(.pip(error.localizedDescription))
        }

        func playerViewControllerWillStopPictureInPicture(_ playerViewController: AVPlayerViewController){
            ComponentLog.d("playerViewControllerWillStopPictureInPicture" , tag: self.tag)
        }

        func playerViewControllerDidStopPictureInPicture(_ playerViewController: AVPlayerViewController){
            ComponentLog.d("playerViewControllerDidStopPictureInPicture" , tag: self.tag)
        }

        func playerViewControllerShouldAutomaticallyDismissAtPictureInPictureStart(_ playerViewController: AVPlayerViewController) -> Bool{
            ComponentLog.d("playerViewControllerShouldAutomaticallyDismissAtPictureInPictureStart" , tag: self.tag)
            return false
        }
        
        func playerViewController(_ playerViewController: AVPlayerViewController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler:
                                    @escaping (Bool) -> Void){
            ComponentLog.d("crestoreUserInterfaceForPictureInPictureStopWithCompletionHandler" , tag: self.tag)
        }
    }
}

protocol CustomPlayerController {
    var viewModel:PlayerModel { get set }
    var playerScreenView:PlayerScreenView  { get set }
    
}

extension CustomPlayerController {
    
    func onViewDidAppear(_ animated: Bool) {
        if CustomAVPlayerController.currentPlayerNum == 0 {
            UIApplication.shared.beginReceivingRemoteControlEvents()
        }
        CustomAVPlayerController.currentPlayerNum += 1
        ComponentLog.d("currentPlayerNum " + CustomAVPlayerController.currentPlayerNum.description, tag:"CustomAVPlayerController")
    }

    func onViewWillDisappear(_ animated: Bool) {
        self.playerScreenView.destory()
        CustomAVPlayerController.currentPlayerNum -= 1
        ComponentLog.d("currentPlayerNum " + CustomAVPlayerController.currentPlayerNum.description, tag:"CustomAVPlayerController")
        if CustomAVPlayerController.currentPlayerNum == 0 {
            UIApplication.shared.endReceivingRemoteControlEvents()
            NotificationCenter.default.post(name: Notification.Name("avPlayerDidDismiss"), object: nil, userInfo: nil)
        }
    }
    
    func onRemoteControlReceived(with event: UIEvent?) {
        guard let type = event?.type else { return}
        if type != .remoteControl { return }
        switch event!.subtype {
        case .remoteControlPause: self.viewModel.event = .pause
        case .remoteControlPlay: self.viewModel.event = .resume
        case .remoteControlEndSeekingForward: self.viewModel.event = .resume
        //case .remoteControlEndSeekingBackward: self.viewModel.event = .seekForward(10, false)
        //case .remoteControlNextTrack: self.viewModel.event = .seekBackword(10, false)
        case .remoteControlPreviousTrack: self.viewModel.remoteEvent = .prev
        default: do{}
        }
    }
}

open class CustomAVPlayerViewController: AVPlayerViewController, CustomPlayerController  {
    var playerScreenView: PlayerScreenView
    @ObservedObject var viewModel:PlayerModel
    init(viewModel:PlayerModel, playerScreenView:PlayerScreenView) {
        self.viewModel = viewModel
        self.playerScreenView = playerScreenView
        super.init(nibName: nil, bundle: nil)
    }
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    open override var canBecomeFirstResponder: Bool { return true }
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let id = self.playerScreenView.playerId
        if CustomAVPlayerController.currentPlayer.first(where: {$0 == id}) == nil {
            CustomAVPlayerController.currentPlayer.append(id)
            self.onViewDidAppear(animated)
        }
        self.becomeFirstResponder()
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let id = self.playerScreenView.playerId
        if let find = CustomAVPlayerController.currentPlayer.firstIndex(of:id) {
            CustomAVPlayerController.currentPlayer.remove(at: find)
            self.onViewWillDisappear(animated)
        }
        self.resignFirstResponder()
    }
    
    open override func remoteControlReceived(with event: UIEvent?) {
        self.onRemoteControlReceived(with: event)
    }
}

open class CustomPlayerViewController: UIViewController, CustomPlayerController {
    var playerScreenView: PlayerScreenView
    @ObservedObject var viewModel:PlayerModel
    init(viewModel:PlayerModel, playerScreenView:PlayerScreenView) {
        self.viewModel = viewModel
        self.playerScreenView = playerScreenView
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override var canBecomeFirstResponder: Bool { return true }
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.onViewDidAppear(animated)
        self.becomeFirstResponder()
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.onViewWillDisappear(animated)
        self.resignFirstResponder()
    }
    
    open override func remoteControlReceived(with event: UIEvent?) {
        self.onRemoteControlReceived(with: event)
    }
}
