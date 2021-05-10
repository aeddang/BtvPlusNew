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
extension CustomAVPlayer: UIViewControllerRepresentable, PlayBack, PlayerScreenViewDelegate {
    func makeUIViewController(context: UIViewControllerRepresentableContext<CustomAVPlayer>) -> UIViewController {
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
    
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<CustomAVPlayer>) {
        ComponentLog.d("updateUIView status " + viewModel.status.rawValue , tag: self.tag)
        if viewModel.status != .update { return }
        guard let evt = viewModel.event else { return }
        guard let player = (uiViewController as? CustomPlayerController)?.playerScreenView else { return }
        if let e = player.player?.error {
            ComponentLog.d("updateUIView error " + e.localizedDescription , tag: self.tag)
        }
        switch viewModel.updateType {
        case .recovery(let t):
             ComponentLog.d("recovery" , tag: self.tag)
             recovery(player, evt: evt, recoveryTime: t)
        case .initate :
             ComponentLog.d("initate" , tag: self.tag)
             recovery(player, evt: evt, recoveryTime: 0)
        default:
             update(player, evt: evt)
        }
    }
    
    private func recovery(_ player: PlayerScreenView, evt:PlayerUIEvent, recoveryTime:Double){
        viewModel.updateType = .update
        var initTime = recoveryTime
        var isPlay = true
        switch evt {
        case .togglePlay: break
        case .resume: break
        case .seekTime(let t, let play):
            initTime = t
            isPlay = play
        case .seekProgress(let pct, let play):
            let t = viewModel.duration * Double(pct)
            isPlay = play
            initTime = t
        default :
            self.update(player, evt: evt)
            return
        }
        viewModel.event = .load(viewModel.path, isPlay , initTime)
    }
    
    private func update(_ player:PlayerScreenView, evt:PlayerUIEvent){
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
        
        func onSeek(time:Double, play:Bool){
            if !player.seek(time) { viewModel.error = .illegalState(evt) }
            var st = min(time, self.viewModel.duration)
            st = max(st, 0)
            //ComponentLog.d("onSeek time " + time.description, tag: self.tag)
            //ComponentLog.d("onSeek st " + st.description, tag: self.tag)
            //ComponentLog.d("onSeek " + self.viewModel.duration.description, tag: self.tag)
            
            self.onSeek(time: st)
            if self.viewModel.isRunning {return}
            if play { onResume() }
            run(player)
        }
        //ComponentLog.d("update evt" , tag: self.tag)
        switch evt {
        case .load(let path, let isAutoPlay, let initTime, let header):
            viewModel.reload()
            if path == "" {viewModel.error = .connect(path)}
            viewModel.path = path
            self.onLoad()
            player.load(path, isAutoPlay: isAutoPlay, initTime: initTime, header:header) 
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
            player.currentVideoGravity = gravity
            
        case .seekTime(let t, let play): onSeek(time:t, play: play)
        case .seekMove(let t, let play): onSeek(time:viewModel.time + t, play: play)
        case .seekForward(let t, let play): onSeek(time:viewModel.time + t, play: play)
        case .seekBackword(let t, let play): onSeek(time:viewModel.time - t, play: play)
        case .seekProgress(let pct, let play):
            let t = viewModel.duration * Double(pct)
            onSeek(time:t, play: play)
            
        case .neetLayoutUpdate :
            player.setNeedsLayout()
        default : do{}
        }
        viewModel.event = nil
    }
    
    private func run(_ player: PlayerScreenView){
        var job:AnyCancellable? = nil
        var timeControlStatus:AVPlayer.TimeControlStatus? = nil
        var status:AVPlayer.Status? = nil
        viewModel.isRunning = true
        job = Timer.publish(every: 0.1, on:.current, in: .common)
            .autoconnect()
            .sink{_ in
                guard let currentPlayer = player.player else {
                    self.cancel(job, reason: "destory plyer")
                    self.onStoped()
                    return
                }
                let t = CMTimeGetSeconds(currentPlayer.currentTime())
                if t >= viewModel.duration && viewModel.duration > 0 {
                    if viewModel.playerStatus != .seek && viewModel.playerStatus != .pause {
                        self.cancel(job, reason: "duration completed")
                        player.pause()
                        self.onTimeChange(viewModel.duration)
                        self.onPaused()
                        self.onCompleted()
                        return
                    }
                }
                self.onTimeChange(Double(t))
                player.layer.setNeedsDisplay()
                if currentPlayer.timeControlStatus != timeControlStatus {
                    switch currentPlayer.timeControlStatus{
                    case .paused:
                        self.cancel(job, reason: "pause")
                        self.onPaused()
    
                    case .playing: self.onResumed()
                    case .waitingToPlayAtSpecifiedRate:
                        switch currentPlayer.reasonForWaitingToPlay {
                        case .some(let reason):
                            switch reason {
                            case .evaluatingBufferingRate: self.onBuffering(rate: 0.0)
                            case .noItemToPlay: self.cancel(job, reason: "noItemToPlay")
                            case .toMinimizeStalls: self.onBuffering(rate: 0.0)
                            default:break
                            }
                        default:break
                        }
                    default:break
                    }
                    timeControlStatus = currentPlayer.timeControlStatus
                }
                if(status != currentPlayer.status){
                    switch currentPlayer.status {
                    case .failed: self.cancel(job, reason: "failed")
                    case .unknown:break
                    case .readyToPlay: do {
                        if let d = currentPlayer.currentItem?.asset.duration {
                            let willDuration = Double(CMTimeGetSeconds(d))
                            if willDuration != viewModel.originDuration {
                                self.onDurationChange(willDuration)
                                player.playInit()
                            }
                        }
                        self.onReadyToPlay()
                    }
                    @unknown default:break
                    }
                    status = currentPlayer.status
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
    
    func onPlayerCompleted(){
        self.onCompleted()
    }

    func onPlayerError(_ error:PlayerStreamError){
        self.onError(error)
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
}

extension MPVolumeView {
    static func setVolume(_ volume: Float) -> Void {
        let volumeView = MPVolumeView(frame: .zero)
        let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider
        volumeView.showsVolumeSlider = false
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {
            slider?.value = volume
            volumeView.showsVolumeSlider = false
        }
        
    }
}

struct CustomAVPlayer {
    @ObservedObject var viewModel:PlayerModel
    @ObservedObject var pageObservable:PageObservable
    @Binding var bindUpdate:Bool 
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
        UIApplication.shared.beginReceivingRemoteControlEvents()
    }

    func onViewWillDisappear(_ animated: Bool) {
        self.playerScreenView.destory()
        UIApplication.shared.endReceivingRemoteControlEvents()
        NotificationCenter.default.post(name: Notification.Name("avPlayerDidDismiss"), object: nil, userInfo: nil)
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
