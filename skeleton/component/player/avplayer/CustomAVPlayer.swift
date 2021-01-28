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

struct CustomAVPlayer {
    @ObservedObject var viewModel:PlayerModel
    func makeCoordinator() -> Coordinator { return Coordinator(viewModel:self.viewModel) }
    
    class Coordinator:NSObject, AVPlayerViewControllerDelegate, PageProtocol {
        @ObservedObject var viewModel:PlayerModel
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
open class CustomAVPlayerViewController: AVPlayerViewController {
    @ObservedObject var viewModel:PlayerModel
    let playerScreenView:PlayerScreenView
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
        self.showsPlaybackControls = false
        UIApplication.shared.beginReceivingRemoteControlEvents()
        self.becomeFirstResponder()
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.viewModel.event = .stop
        UIApplication.shared.endReceivingRemoteControlEvents()
        NotificationCenter.default.post(name: Notification.Name("avPlayerDidDismiss"), object: nil, userInfo: nil)
        self.resignFirstResponder()
    }
    
    open override func remoteControlReceived(with event: UIEvent?) {
        guard let type = event?.type else { return}
        if type != .remoteControl { return }
        switch event!.subtype {
        case .remoteControlPause: self.viewModel.event = .pause
        case .remoteControlPlay: self.viewModel.event = .resume
        default: do{}
        }
    }
}


extension CustomAVPlayer: UIViewControllerRepresentable, PlayBack, PlayerScreenViewDelegate {
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<CustomAVPlayer>) -> AVPlayerViewController {
        let playerScreenView = PlayerScreenView(frame: .zero)
        let playerController = CustomAVPlayerViewController(viewModel: self.viewModel, playerScreenView: playerScreenView)
        playerController.delegate = context.coordinator
        playerScreenView.delegate = self
        playerScreenView.playerController = playerController
        return playerController
    }
    func updateUIViewController(_ uiViewController:  AVPlayerViewController, context: UIViewControllerRepresentableContext<CustomAVPlayer>) {
        if viewModel.status != .update { return }
        guard let evt = viewModel.event else { return }
        guard let player = (uiViewController as? CustomAVPlayerViewController)?.playerScreenView else { return }
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
             ComponentLog.d("updateUIView" , tag: self.tag)
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
            self.onSeek()
            if self.viewModel.isRunning {return}
            if play { onResume() }
            run(player)
        }
        ComponentLog.d("update evt" , tag: self.tag)
        switch evt {
        case .load(let path, let isAutoPlay, let initTime, let header):
            viewModel.reset()
            if path == "" {viewModel.error = .connect(path)}
            viewModel.path = path
            self.onLoad()
            player.load(path, isAutoPlay: isAutoPlay, initTime: initTime, header:header)
            run(player)
        case .check:
            run(player)
        case .togglePlay:
            if self.viewModel.isPlay {  onPause() } else { onResume() }
        case .resume: onResume()
        case .pause: onPause()
        case .stop:
            ComponentLog.d("stop" , tag: self.tag)
            player.stop()
        case .volume(let v):
            player.currentVolume = v
            viewModel.volume = v
        case .seekTime(let t, let play): onSeek(time:t, play: play)
        case .seekMove(let t, let play): onSeek(time:viewModel.time + t, play: play)
        case .seekProgress(let pct, let play):
            let t = viewModel.duration * Double(pct)
            onSeek(time:t, play: play)
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
                            self.onDurationChange(Double(CMTimeGetSeconds(d)))
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
        self.viewModel.volume = v
    }
}

protocol PlayerScreenViewDelegate{
    func onPlayerError(_ error:PlayerStreamError)
    func onPlayerCompleted()
    func onPlayerBecomeActive()
    func onPlayerVolumeChanged(_ v:Float)
}

class PlayerScreenView: UIView, PageProtocol {
    
    var currentVolume:Float = 1.0
    {
        didSet{
            player?.volume = currentVolume
        }
    }
    var delegate:PlayerScreenViewDelegate?
    var player:AVPlayer? = nil
    private var recoveryTime:Double = -1
    let playerLayer = AVPlayerLayer()
    var playerController : AVPlayerViewController? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.addSublayer(playerLayer)
    }
    required init?(coder: NSCoder) {fatalError("init(coder:) has not been implemented")}
    
    deinit {
        ComponentLog.d("deinit" , tag: self.tag)
        destoryPlayer()
        delegate = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
    
    private func createPlayer(_ url:URL, buffer:Double = 2.0, header:[String:String]? = nil) -> AVPlayer?{
        destoryPlayer()
        if let header = header {
            player = AVPlayer(url: url)
            startPlayer(url, header: header)
        }else{
            player = AVPlayer(url: url)
            startPlayer()
        }
        return player
    }
    
    private func startPlayer(_ url:URL, header:[String:String]){
        var assetHeader = [String: Any]()
        assetHeader["AVURLAssetHTTPHeaderFieldsKey"] = header
        let key = "playable"
        let asset = AVURLAsset(url: url, options: assetHeader)
        asset.loadValuesAsynchronously(forKeys: [key]){
            DispatchQueue.main.async {
                let status = asset.statusOfValue(forKey: key, error: nil)
                switch (status)
                {
                case AVKeyValueStatus.failed, AVKeyValueStatus.cancelled, AVKeyValueStatus.unknown:
                    ComponentLog.d("certification fail " + url.absoluteString , tag: self.tag)
                    self.onError(.certification(status.rawValue.description))
                default:
                    ComponentLog.d("certification success " + url.absoluteString , tag: self.tag)
                    let item = AVPlayerItem(asset: asset)
                    self.player?.replaceCurrentItem(with: item )
                    self.startPlayer()
                    break;
                }
            }
        }
    }
    
    static let VOLUME_NOTIFY_KEY = "AVSystemController_SystemVolumeDidChangeNotification"
    static let VOLUME_PARAM_KEY = "AVSystemController_AudioVolumeNotificationParameter"
    private func startPlayer(){
        player?.allowsExternalPlayback = true
        player?.usesExternalPlaybackWhileExternalScreenIsActive = true
        player?.preventsDisplaySleepDuringVideoPlayback = true
        player?.volume = currentVolume
        playerLayer.player = player
        playerLayer.videoGravity = .resizeAspectFill
        playerController?.player = player
        //player?.addPeriodicTimeObserver(forInterval: <#T##CMTime#>, queue: <#T##DispatchQueue?#>, using: <#T##(CMTime) -> Void#>)
        //ComponentLog.d("startPlayer " + playerLayer.isReadyForDisplay.description , tag: self.tag)
        
        //player?.addObserver(self, forKeyPath: #keyPath(AVPlayer.status), options: [.new, .initial], context: nil)
        //player?.addObserver(self, forKeyPath: #keyPath(AVPlayer.currentItem.status), options:[.new, .initial], context: nil)
        
        let center = NotificationCenter.default
        center.addObserver(self, selector:#selector(newErrorLogEntry), name: .AVPlayerItemNewErrorLogEntry, object: nil)
        center.addObserver(self, selector:#selector(failedToPlayToEndTime), name: .AVPlayerItemFailedToPlayToEndTime, object: nil)
        center.addObserver(self, selector: #selector(playerItemDidReachEnd), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        center.addObserver(self, selector: #selector(playerDidBecomeActive), name: UIApplication.didBecomeActiveNotification , object: nil)
        center.addObserver(self, selector: #selector(systemVolumeChange), name: NSNotification.Name(rawValue: Self.VOLUME_NOTIFY_KEY) , object: nil)
    }
    
    private func destoryPlayer(){
        ComponentLog.d("destoryPlayer " + player.debugDescription, tag: self.tag)
        guard let prevPlayer = player else { return }
        
        prevPlayer.pause()
        playerLayer.player = nil
        playerController?.player = nil
        playerController?.delegate = nil
        NotificationCenter.default.removeObserver(self)
    }
    
    private func onError(_ e:PlayerStreamError){
         delegate?.onPlayerError(e)
         destoryPlayer()
    }
    
    @objc func newErrorLogEntry(_ notification: Notification) {
        guard let object = notification.object, let playerItem = object as? AVPlayerItem else { return}
        guard let errorLog: AVPlayerItemErrorLog = playerItem.errorLog() else { return }
        ComponentLog.d("errorLog " + errorLog.description , tag: self.tag)
        
    }

    @objc func failedToPlayToEndTime(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        let e = userInfo[AVPlayerItemFailedToPlayToEndTimeErrorKey]
        if let error = e as? Error {
            onError(.playback(error.localizedDescription))
        }else{
            onError(.unknown("failedToPlayToEndTime"))
        }
        
    }
    @objc func playerItemDidReachEnd(notification: NSNotification) {
        delegate?.onPlayerCompleted()
    }
    @objc func playerDidBecomeActive(notification: NSNotification) {
        delegate?.onPlayerBecomeActive()
    }
    @objc func systemVolumeChange(notification: NSNotification) {
        guard let volume = notification.userInfo?[Self.VOLUME_PARAM_KEY] as? Float else { return }
        delegate?.onPlayerVolumeChanged(volume)
    }
    
    
    @discardableResult
    func load(_ path:String, isAutoPlay:Bool = false , initTime:Double = 0, buffer:Double = 2.0, header:[String:String]? = nil) -> AVPlayer? {
        guard let url = URL(string: path) else {
           return nil
        }
        let player = createPlayer(url, buffer:buffer, header:header)
        if isAutoPlay { resume() }
        if initTime > 0 { seek(initTime) }
        return player
    }
    func stop() {
        destoryPlayer()
    }
    
    @discardableResult
    func resume() -> Bool {
        guard let currentPlayer = player else { return false }
        currentPlayer.play()
        return true
    }
    
    @discardableResult
    func pause() -> Bool {
        guard let currentPlayer = player else { return false }
        currentPlayer.pause()
        return true
    }
    
    @discardableResult
    func seek(_ t:Double) -> Bool {
        guard let currentPlayer = player else { return false }
        let cmt = CMTime(
            value: CMTimeValue(t * PlayerModel.TIME_SCALE),
            timescale: CMTimeScale(PlayerModel.TIME_SCALE))
        currentPlayer.seek(to: cmt)
        return true
    }
}
