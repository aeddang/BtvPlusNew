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

extension CustomAVPlayerController: UIViewControllerRepresentable,
                                    PlayBack, PlayerScreenViewDelegate , CustomPlayerControllerDelegate{
    
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
            playerScreenView.delegate = self
            playerScreenView.playerDelegate = playerController
            playerScreenView.playerController = playerController
            playerController.delegate = context.coordinator
            playerController.playerDelegate = self
            return playerController
        }else{
            let playerController = CustomPlayerViewController(viewModel: self.viewModel, playerScreenView: playerScreenView)
            playerScreenView.delegate = self
            playerScreenView.playerDelegate = playerController
            playerScreenView.playerLayer = AVPlayerLayer()
            playerController.view = playerScreenView
            playerController.playerDelegate = self
            return playerController
        }
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<CustomAVPlayerController>) {
        //ComponentLog.d("updateUIView status " + viewModel.id , tag: self.tag)
        if viewModel.status != .update { return }
        guard let evt = viewModel.event else { return }
        guard let playerController = uiViewController as? CustomPlayerController else { return }
        let player = playerController.playerScreenView
        
        if let e = player.player?.error {
            ComponentLog.d("updateUIView error " + e.localizedDescription , tag: self.tag)
        }
        switch viewModel.updateType {
        case .recovery(let t, let count):
             ComponentLog.d("recovery" , tag: self.tag)
             recovery(playerController, evt: evt, recoveryTime: t, retryCount: count)
        case .initate :
             ComponentLog.d("initate" , tag: self.tag)
             recovery(playerController, evt: evt, recoveryTime: 0)
        default:
             update(playerController, evt: evt)
        }
    }
    
    private func recovery(_ player: CustomPlayerController, evt:PlayerUIEvent, recoveryTime:Double, retryCount:Int = -1){
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
    
    private func update(_ player:CustomPlayerController, evt:PlayerUIEvent){
        DispatchQueue.main.async {
            self.updateExcute(player, evt:evt)
        }
        viewModel.event = nil
    }
    
    
    private func updateExcute(_ playerController:CustomPlayerController, evt:PlayerUIEvent) {
        let player = playerController.playerScreenView
        switch evt {
        case .load(let path, let isAutoPlay, let initTime, let header):
            viewModel.reload()
            if path == "" {return}
            viewModel.path = path
            self.onLoad()
            player.currentRate = self.viewModel.rate
            player.currentVideoGravity = self.viewModel.screenGravity
            player.currentRatio = self.viewModel.screenRatio
            player.mute(viewModel.isMute)
            player.load(path, isAutoPlay: isAutoPlay, initTime: initTime, header:header, assetInfo: self.viewModel.assetInfo, drmData: viewModel.drm)
        case .check:
            if self.viewModel.isRunning {return}
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
            viewModel.rate = r
            player.currentRate = r
            
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
        }
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
    func onPlayerTimeChange(_ playerController: CustomPlayerController, t:CMTime){
        let t = CMTimeGetSeconds(t)
        let d = viewModel.duration
        if d > 0 {
            if viewModel.isReplay && t >= (d - 1) {
                self.viewModel.event = .seekTime(0, true)
            }
            if t == d {
                if viewModel.playerStatus != .seek && viewModel.playerStatus != .pause {
                    playerController.playerScreenView.player?.pause()
                    self.onTimeChange(viewModel.duration)
                    self.onPaused()
                    self.onCompleted()
                    return
                }
            }
        }
        //CmponentLog.d("Timer " + t.description , tag: self.tag)
        self.onTimeChange(Double(t))
        
    }
    func onPlayerTimeControlChange(_ playerController: CustomPlayerController, status:AVPlayer.TimeControlStatus){
        switch status {
        case .paused:
            DispatchQueue.main.async {
                self.onPaused()
            }
        case .playing:
            DispatchQueue.main.async {
                self.onResumed()
            }
        //case .waitingToPlayAtSpecifiedRate:
          // DispatchQueue.main.async {self.onBuffering(rate: 0.0)}
        default:break
        }
    }
    func onPlayerStatusChange(_ playerController: CustomPlayerController, status:AVPlayer.Status){
        switch status {
        case .failed:
            DispatchQueue.main.async {
                self.onPlayerError(.playback("failed"))
            }
        case .unknown:break
        case .readyToPlay:
            if let player = playerController.playerScreenView.player {
                if let d = player.currentItem?.asset.duration {
                    let willDuration = Double(CMTimeGetSeconds(d))
                    if willDuration != viewModel.originDuration {
                        DispatchQueue.main.async {
                            self.onDurationChange(willDuration)
                            playerController.playerScreenView.playInit(duration: willDuration)
                        }
                    }
                }
            }
            DispatchQueue.main.async {
                self.onReadyToPlay()
            }
    
        @unknown default:break
        }
    }
    func onReasonForWaitingToPlay(_ playerController: CustomPlayerController, reason:AVPlayer.WaitingReason){
        switch reason {
        case .evaluatingBufferingRate:
            DispatchQueue.main.async {self.onBuffering(rate: 0.0)}
        case .noItemToPlay:
            DispatchQueue.main.async {self.onBuffering(rate: 0.0)}
        case .toMinimizeStalls:
            DispatchQueue.main.async {self.onToMinimizeStalls()}
        default:break
        }
    }
    
    func onPlayerItemStatusChange(_ playerScreenView: CustomPlayerController, status:AVPlayerItem.Status){
        switch status {
        case .failed:
            ComponentLog.d("onPlayerItemStatusChange failed" , tag: self.tag)
        case .unknown:
            ComponentLog.d("onPlayerItemStatusChange unknown" , tag: self.tag)
        case .readyToPlay:
            ComponentLog.d("onPlayerItemStatusChange readyToPlay" , tag: self.tag)
        @unknown default:break
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

protocol CustomPlayerControllerDelegate{
    func onPlayerTimeChange(_ playerController: CustomPlayerController, t:CMTime)
    func onPlayerTimeControlChange(_ playerController: CustomPlayerController, status:AVPlayer.TimeControlStatus)
    func onPlayerStatusChange(_ playerController: CustomPlayerController, status:AVPlayer.Status)
    func onPlayerItemStatusChange(_ playerController: CustomPlayerController, status:AVPlayerItem.Status)
    func onReasonForWaitingToPlay(_ playerController: CustomPlayerController, reason:AVPlayer.WaitingReason)
}

protocol CustomPlayerController {
    var viewModel:PlayerModel { get set }
    var playerScreenView:PlayerScreenView  { get set }
    var playerDelegate:CustomPlayerControllerDelegate?  { get set }
    var currentTimeObservser:Any? { get set }
    
    func run()
    func cancel()
}

extension CustomPlayerController {
    func onViewDidAppear(_ animated: Bool) {
        if CustomAVPlayerController.currentPlayerNum == 0 {
            UIApplication.shared.beginReceivingRemoteControlEvents()
        }
        CustomAVPlayerController.currentPlayerNum += 1
        ComponentLog.d("currentPlayerNum " + CustomAVPlayerController.currentPlayerNum.description, tag:"CustomAVPlayerController2")
    }
    func onViewWillDisappear(_ animated: Bool) {
        self.cancel()
        self.playerScreenView.destory()
        CustomAVPlayerController.currentPlayerNum -= 1
        ComponentLog.d("currentPlayerNum " + CustomAVPlayerController.currentPlayerNum.description, tag:"CustomAVPlayerController2")
        if CustomAVPlayerController.currentPlayerNum == 0 {
            UIApplication.shared.endReceivingRemoteControlEvents()
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
    
    func onPlayerItemStatusChange(_ playerController: CustomPlayerController, status:AVPlayerItem.Status){}
    func onReasonForWaitingToPlay(_ playerController: CustomPlayerController, reason:AVPlayer.WaitingReason){}
}

open class CustomPlayerViewController: UIViewController, CustomPlayerController , PlayerScreenPlayerDelegate{
    var playerDelegate: CustomPlayerControllerDelegate? = nil
    var playerScreenView: PlayerScreenView
    var viewModel:PlayerModel
    var currentTimeObservser:Any? = nil
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
        let id = self.playerScreenView.id
        if CustomAVPlayerController.currentPlayer.first(where: {$0 == id}) == nil {
            CustomAVPlayerController.currentPlayer.append(id)
            self.onViewDidAppear(animated)
        }
        //self.becomeFirstResponder()
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let id = self.playerScreenView.id
        if let find = CustomAVPlayerController.currentPlayer.firstIndex(of:id) {
            CustomAVPlayerController.currentPlayer.remove(at: find)
            self.onViewWillDisappear(animated)
        }
        // self.resignFirstResponder()
    }
    
    open override func remoteControlReceived(with event: UIEvent?) {
        self.onRemoteControlReceived(with: event)
    }
    
    func onPlayerReady() {
        self.run()
    }
    
    func onPlayerDestory() {
        self.cancel()
    }
    
    func run(){
        guard let player = self.playerScreenView.player else {return}
        //DispatchQueue.global(qos: .background).async {
        self.currentTimeObservser = player.addPeriodicTimeObserver(
            forInterval: CMTimeMakeWithSeconds(1,preferredTimescale: Int32(NSEC_PER_SEC)),
            queue: nil){ time in
            self.playerDelegate?.onPlayerTimeChange(self, t:time)
        }
    
        player.addObserver(self, forKeyPath: #keyPath(AVPlayer.status), options: [.new], context: nil)
        //player.addObserver(self, forKeyPath: #keyPath(AVPlayer.reasonForWaitingToPlay), options: [.new], context: nil)
        //player.addObserver(self, forKeyPath: #keyPath(AVPlayer.currentItem.status), options:[.new], context: nil)
        player.addObserver(self, forKeyPath: #keyPath(AVPlayer.timeControlStatus), options:[.new], context: nil)
        //}
    }
    func cancel() {
        guard let player = self.playerScreenView.player else {return}
        guard let currentTimeObservser = self.currentTimeObservser else {return}
        player.removeTimeObserver(currentTimeObservser)
        player.removeObserver(self, forKeyPath: #keyPath(AVPlayer.status))
        //player.removeObserver(self, forKeyPath: #keyPath(AVPlayer.reasonForWaitingToPlay))
        //player.removeObserver(self, forKeyPath: #keyPath(AVPlayer.currentItem.status))
        player.removeObserver(self, forKeyPath: #keyPath(AVPlayer.timeControlStatus))
        self.currentTimeObservser = nil
    }
    
    open override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?){
        
        
        switch keyPath {
        case #keyPath(AVPlayer.status) :
            if let num = change?[.newKey] as? Int {
                self.playerDelegate?.onPlayerStatusChange(self, status: AVPlayer.Status(rawValue: num) ?? .unknown)
            } else {
                self.playerDelegate?.onPlayerStatusChange(self, status: .unknown)
            }
        case #keyPath(AVPlayer.currentItem.status) :
            if let num = change?[.newKey] as? Int {
                self.playerDelegate?.onPlayerItemStatusChange(self, status: AVPlayerItem.Status(rawValue: num) ?? .unknown)
            } else {
                self.playerDelegate?.onPlayerItemStatusChange(self, status: .unknown)
            }
        case #keyPath(AVPlayer.timeControlStatus) :
            if let num = change?[.newKey] as? Int,
               let status = AVPlayer.TimeControlStatus(rawValue: num) {
                self.playerDelegate?.onPlayerTimeControlChange(self, status: status)
            }
        case #keyPath(AVPlayer.reasonForWaitingToPlay) :
            if let str = change?[.newKey] as? String{
                let reason = AVPlayer.WaitingReason(rawValue: str)
                self.playerDelegate?.onReasonForWaitingToPlay(self, reason: reason)
            }
        default : break
        
        }
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

//기본UI

open class CustomAVPlayerViewController: AVPlayerViewController, CustomPlayerController, PlayerScreenPlayerDelegate {
    var viewModel:PlayerModel
    var playerScreenView: PlayerScreenView
    var playerDelegate:CustomPlayerControllerDelegate?
    var currentTimeObservser:Any? = nil
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
        let id = self.playerScreenView.id
        if CustomAVPlayerController.currentPlayer.first(where: {$0 == id}) == nil {
            CustomAVPlayerController.currentPlayer.append(id)
            self.onViewDidAppear(animated)
        }
        //self.becomeFirstResponder()
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let id = self.playerScreenView.id
        if let find = CustomAVPlayerController.currentPlayer.firstIndex(of:id) {
            CustomAVPlayerController.currentPlayer.remove(at: find)
            self.onViewWillDisappear(animated)
        }
        //self.resignFirstResponder()
    }
    
    open override func remoteControlReceived(with event: UIEvent?) {
        self.onRemoteControlReceived(with: event)
    }
    
    func onPlayerReady() {
        self.run()
    }
    func onPlayerDestory() {
        self.cancel()
    }
    
    
    func run(){
        guard let player = self.playerScreenView.player else {return}
        self.cancel()
        
        self.currentTimeObservser = player.addPeriodicTimeObserver(
            forInterval: CMTimeMakeWithSeconds(1.0,preferredTimescale: Int32(NSEC_PER_SEC)),
            queue: nil){ time in
            self.playerDelegate?.onPlayerTimeChange(self, t:time)
        }
        player.addObserver(self, forKeyPath: #keyPath(AVPlayer.status), options: [.new], context: nil)
        player.addObserver(self, forKeyPath: #keyPath(AVPlayer.currentItem.status), options:[.new], context: nil)
        player.addObserver(self, forKeyPath: #keyPath(AVPlayer.timeControlStatus), options:[.new], context: nil)
         
    }
    func cancel() {
        guard let player = self.playerScreenView.player else {return}
        if let currentTimeObservser = self.currentTimeObservser {
            player.removeTimeObserver(currentTimeObservser)
            self.currentTimeObservser = nil
        }
        player.removeObserver(self, forKeyPath: #keyPath(AVPlayer.status))
        player.removeObserver(self, forKeyPath: #keyPath(AVPlayer.currentItem.status))
        player.removeObserver(self, forKeyPath: #keyPath(AVPlayer.timeControlStatus))
    }
    
    open override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?){
        
        switch keyPath {
        case #keyPath(AVPlayer.status) :
            if let num = change?[.newKey] as? Int {
                self.playerDelegate?.onPlayerStatusChange(self, status: AVPlayer.Status(rawValue: num) ?? .unknown)
            } else {
                self.playerDelegate?.onPlayerStatusChange(self, status: .unknown)
            }
        case #keyPath(AVPlayer.currentItem.status) :
            if let num = change?[.newKey] as? Int {
                self.playerDelegate?.onPlayerItemStatusChange(self, status: AVPlayerItem.Status(rawValue: num) ?? .unknown)
            } else {
                self.playerDelegate?.onPlayerItemStatusChange(self, status: .unknown)
            }
        case #keyPath(AVPlayer.timeControlStatus) :
            if let num = change?[.newKey] as? Int,
               let status = AVPlayer.TimeControlStatus(rawValue: num) {
                self.playerDelegate?.onPlayerTimeControlChange(self, status: status)
            }
        default : break
        
        }
    }
    
}
