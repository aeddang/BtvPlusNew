//
//  PlayerScreenView.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/02/04.
//

import Foundation
import SwiftUI
import Combine
import AVKit
import MediaPlayer

protocol PlayerScreenViewDelegate{
    func onPlayerError(_ error:PlayerStreamError)
    func onPlayerCompleted()
    func onPlayerBecomeActive()
    func onPlayerVolumeChanged(_ v:Float)
}

class PlayerScreenView: UIView, PageProtocol {
    
    var delegate:PlayerScreenViewDelegate?
    var player:AVPlayer? = nil
    {
        didSet{
            if let pl = playerLayer {
                layer.addSublayer(pl)
            }
        }
    }
    var currentRatio:CGFloat = 1.0
    {
        didSet{
            ComponentLog.d("onCurrentRatio " + currentRatio.description, tag: self.tag)
            if let layer = playerLayer {
                layer.contentsScale = currentRatio
                self.setNeedsLayout()
            }
        }
    }
    
    var currentVideoGravity:AVLayerVideoGravity = .resizeAspectFill
    {
        didSet{
             playerLayer?.videoGravity = currentVideoGravity
             if let avPlayerViewController = playerController as? AVPlayerViewController {
                 avPlayerViewController.videoGravity = currentVideoGravity
             }
        }
    }
    
    var currentRate:Float = 1.0
    {
        didSet{
            player?.rate = currentRate
        }
    }
    
    private var recoveryTime:Double = -1
    var playerLayer:AVPlayerLayer? = nil
    var playerController : UIViewController? = nil
   
    private var currentVolume:Float = 1.0
    private var isAutoPlay:Bool = false
    private var initTime:Double = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder: NSCoder) {fatalError("init(coder:) has not been implemented")}
    
    deinit {
        ComponentLog.d("deinit" , tag: self.tag)
        destory()
    }
    func destory(){
        ComponentLog.d("destory" , tag: self.tag)
        destoryPlayer()
        delegate = nil
        playerController = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let w = bounds.width * currentRatio
        let h = bounds.height * currentRatio
        let x = (bounds.width - w) / 2
        let y = (bounds.height - h) / 2
        playerLayer?.frame = CGRect(x: x, y: y, width: w, height: h)
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
        if self.isAutoPlay { resume() }
        else { pause() }
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
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
        }
        catch {
            ComponentLog.e("Setting category to AVAudioSessionCategoryPlayback failed." , tag: self.tag)
        }
        
        
        if let avPlayerViewController = playerController as? AVPlayerViewController {
            avPlayerViewController.player = player
            avPlayerViewController.updatesNowPlayingInfoCenter = false
            avPlayerViewController.videoGravity = currentVideoGravity
        }else{
            playerLayer?.player = player
            playerLayer?.contentsScale = currentRatio
            playerLayer?.videoGravity = currentVideoGravity
        }
        //player?.addPeriodicTimeObserver(forInterval: <#T##CMTime#>, queue: <#T##DispatchQueue?#>, using: <#T##(CMTime) -> Void#>)
        ComponentLog.d("startPlayer currentVolume " + currentVolume.description , tag: self.tag)
        ComponentLog.d("startPlayer currentRate " + currentRate.description , tag: self.tag)
        ComponentLog.d("startPlayer videoGravity " + currentVideoGravity.rawValue , tag: self.tag)
        
        //player?.addObserver(self, forKeyPath: #keyPath(AVPlayer.status), options: [.new, .initial], context: nil)
        //player?.addObserver(self, forKeyPath: #keyPath(AVPlayer.currentItem.status), options:[.new, .initial], context: nil)
        
        let center = NotificationCenter.default
        NotificationCenter.default.removeObserver(self)
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
        playerLayer?.player = nil
        if let avPlayerViewController = playerController as? AVPlayerViewController {
            avPlayerViewController.player = nil
            avPlayerViewController.delegate = nil
        }
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
        self.initTime = initTime
        self.isAutoPlay = isAutoPlay
    
        let player = createPlayer(url, buffer:buffer, header:header)
        return player
    }
    
    func playInit(){
        if self.initTime > 0 {
            seek(initTime)
        }
        guard let currentPlayer = player else { return }
        currentPlayer.rate = self.currentRate
        if !self.isAutoPlay { pause() }
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
    
    
    @discardableResult
    func mute(_ isMute:Bool) -> Bool {
        currentVolume = isMute ? 0.0 : 1.0
        guard let currentPlayer = player else { return false }
        currentPlayer.volume = currentVolume

        return true
    }
}
