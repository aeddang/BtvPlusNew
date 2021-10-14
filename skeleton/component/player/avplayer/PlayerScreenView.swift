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
    func onPlayerAssetInfo(_ info:AssetPlayerInfo)
    func onPlayerError(_ error:PlayerStreamError)
    func onPlayerError(playerError:PlayerError)
    func onPlayerCompleted()
    func onPlayerBecomeActive()
    //func onPlayerVolumeChanged(_ v:Float)
    func onPlayerBitrateChanged(_ bitrate:Double)
}

protocol PlayerScreenPlayerDelegate{
    func onPlayerReady()
    func onPlayerDestory()
}

class PlayerScreenView: UIView, PageProtocol, CustomAssetPlayerDelegate , Identifiable{
    let id:String = UUID.init().uuidString
    var delegate:PlayerScreenViewDelegate? = nil
    var playerDelegate:PlayerScreenPlayerDelegate? = nil
    var drmData:FairPlayDrm? = nil
    var playerController : UIViewController? = nil
    var playerLayer:AVPlayerLayer? = nil
    
    private(set) var player:AVPlayer? = nil
    {
        didSet{
            if player != nil {
                if let pl = playerLayer {
                    layer.addSublayer(pl)
                }
            }
        }
    }

    private var currentTimeObservser:Any? = nil
    private var currentVolume:Float = 1.0
    private var isAutoPlay:Bool = false
    private var initTime:Double = 0
    private var recoveryTime:Double = -1
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        ComponentLog.d("init " + id, tag: self.tag)
    }
    
    required init?(coder: NSCoder) {fatalError("init(coder:) has not been implemented")}
    
    deinit {
        ComponentLog.d("deinit " + id, tag: self.tag)
        self.destoryScreenview()
    }
    
    func destory(){
        ComponentLog.d("destory " + id , tag: self.tag)
        self.destoryPlayer()
        self.destoryScreenview()
    }
    func destoryScreenview(){
        delegate = nil
        playerController = nil
        ComponentLog.d("destoryScreenview " + id, tag: self.tag)
    }
    private func destoryPlayer(){
        guard let player = self.player else {return}
        player.pause()
        player.replaceCurrentItem(with: nil)
        playerLayer?.player = nil
        if let avPlayerViewController = playerController as? AVPlayerViewController {
            avPlayerViewController.player = nil
            avPlayerViewController.delegate = nil
        }
        NotificationCenter.default.removeObserver(self)
        self.playerDelegate?.onPlayerDestory()
        self.player = nil
        ComponentLog.d("destoryPlayer " + id, tag: self.tag)
    }
    
    private func createdPlayer(){
        self.playerDelegate?.onPlayerReady()
        let center = NotificationCenter.default
        //center.addObserver(self, selector:#selector(newErrorLogEntry), name: .AVPlayerItemNewErrorLogEntry, object: nil)
        center.addObserver(self, selector:#selector(failedToPlayToEndTime), name: .AVPlayerItemFailedToPlayToEndTime, object: nil)
        center.addObserver(self, selector: #selector(playerItemDidReachEnd), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        center.addObserver(self, selector: #selector(playerDidBecomeActive), name: UIApplication.didBecomeActiveNotification , object: nil)
        /*
        center.addObserver(self, selector: #selector(systemVolumeChange), name: NSNotification.Name(rawValue: Self.VOLUME_NOTIFY_KEY) , object: nil)*/
        //center.addObserver(self, selector: #selector(playerItemBitrateChange), name: .AVPlayerItemNewAccessLogEntry , object: nil)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let w = bounds.width * currentRatio
        let h = bounds.height * currentRatio
        let x = (bounds.width - w) / 2
        let y = (bounds.height - h) / 2
        playerLayer?.frame = CGRect(x: x, y: y, width: w, height: h)
    }
    
    private func createPlayer(_ url:URL, buffer:Double = 2.0, header:[String:String]? = nil, assetInfo:AssetPlayerInfo? = nil) -> AVPlayer?{
        self.destoryPlayer()
        var player:AVPlayer? = nil
        if self.drmData != nil {
            player = startPlayer(url, assetInfo:assetInfo)
        }else if let header = header {
            player = startPlayer(url, header: header)
        }else{
            player = startPlayer(url, assetInfo:assetInfo)
        }
        return player
    }
    
    private let loaderQueue = DispatchQueue(label: "resourceLoader")
    
    private func startPlayer(_ url:URL, header:[String:String]) -> AVPlayer?{
       
        let player = AVPlayer()
        var assetHeader = [String: Any]()
        assetHeader["AVURLAssetHTTPHeaderFieldsKey"] = header
        let key = "playable"
        let asset = AVURLAsset(url: url, options: assetHeader)
        asset.loadValuesAsynchronously(forKeys: [key]){
            DispatchQueue.global(qos: .background).async {
                let status = asset.statusOfValue(forKey: key, error: nil)
                switch (status)
                {
                case AVKeyValueStatus.failed, AVKeyValueStatus.cancelled, AVKeyValueStatus.unknown:
                    ComponentLog.d("certification fail " + url.absoluteString , tag: self.tag)
                    DispatchQueue.main.async {
                        self.onError(.certification(status.rawValue.description))
                    }
                default:
                    //ComponentLog.d("certification success " + url.absoluteString , tag: self.tag)
                    DispatchQueue.main.async {
                        let item = AVPlayerItem(asset: asset)
                        player.replaceCurrentItem(with: item )
                        self.startPlayer(player:player)
                    }
                    break;
                }
            }
        }
        return player
    }
    
    private func startPlayer(_ url:URL, assetInfo:AssetPlayerInfo? = nil)  -> AVPlayer?{
        ComponentLog.d("DrmData " +  (drmData?.contentId ?? "none drm") , tag: self.tag)
        if self.drmData == nil {
            player = AVPlayer()
            let asset = AVURLAsset(url: url)
            let item = AVPlayerItem(asset: asset)
            player?.replaceCurrentItem(with: item )
           
        } else {
            player = CustomAssetPlayer(m3u8URL: url, playerDelegate: self, assetInfo:assetInfo, drm: self.drmData)
        }
        //player = FairplayPlayer(m3u8URL: url, playerDelegate: self, assetInfo:assetInfo, drm:self.drmData)
        self.startPlayer()
        return self.player
    }
    

    static let VOLUME_NOTIFY_KEY = "AVSystemController_SystemVolumeDidChangeNotification"
    static let VOLUME_PARAM_KEY = "AVSystemController_AudioVolumeNotificationParameter"
    private func startPlayer(){
        guard let player = self.player else { return }
        self.startPlayer(player:player)
    }
    private func startPlayer(player:AVPlayer){
        //DispatchQueue.global(qos: .default).async {
            self.player = player
            player.allowsExternalPlayback = false
            player.usesExternalPlaybackWhileExternalScreenIsActive = true
            player.preventsDisplaySleepDuringVideoPlayback = true
            player.volume = self.currentVolume
            //player.rate = currentRate
            //player?.isClosedCaptionDisplayEnabled = true
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            }
            catch {
                ComponentLog.e("Setting category to AVAudioSessionCategoryPlayback failed." , tag: self.tag)
            }
            
            if let avPlayerViewController = self.playerController as? AVPlayerViewController {
                avPlayerViewController.player = player
                avPlayerViewController.updatesNowPlayingInfoCenter = false
                avPlayerViewController.videoGravity = self.currentVideoGravity
            }else{
                self.playerLayer?.player = player
                self.playerLayer?.contentsScale = self.currentRatio
                self.playerLayer?.videoGravity = self.currentVideoGravity
            }
            
            ComponentLog.d("startPlayer currentVolume " + self.currentVolume.description , tag: self.tag)
            ComponentLog.d("startPlayer currentRate " + self.currentRate.description , tag: self.tag)
            ComponentLog.d("startPlayer videoGravity " + self.currentVideoGravity.rawValue , tag: self.tag)
            self.createdPlayer()
            
        //}
    }
    

    private func onError(_ e:PlayerStreamError){
        delegate?.onPlayerError(e)
        ComponentLog.e("onError " + e.getDescription(), tag: self.tag)
        destoryScreenview()
    }
    
    @objc func newErrorLogEntry(_ notification: Notification) {
        guard let object = notification.object, let playerItem = object as? AVPlayerItem else { return}
        guard let errorLog: AVPlayerItemErrorLog = playerItem.errorLog() else { return }
        ComponentLog.d("errorLog " + errorLog.description , tag: self.tag)
        //delegate?.onPlayerError(.playback(notification.description))
        //destoryScreenview()
        
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
    /*
    @objc func systemVolumeChange(notification: NSNotification) {
        guard let volume = notification.userInfo?[Self.VOLUME_PARAM_KEY] as? Float else { return }
        delegate?.onPlayerVolumeChanged(volume)
    }*/
    
    @objc func playerItemBitrateChange(notification: NSNotification) {
        DispatchQueue.global(qos: .background).async {
            guard let item = notification.object as? AVPlayerItem else {return}
            guard let bitrate = item.accessLog()?.events.last?.indicatedBitrate else {return}
            DispatchQueue.main.async {
                self.delegate?.onPlayerBitrateChanged(bitrate)
            }
        }
       
    }
    
    @discardableResult
    func load(_ path:String, isAutoPlay:Bool = false , initTime:Double = 0,buffer:Double = 2.0,
              header:[String:String]? = nil,
              assetInfo:AssetPlayerInfo? = nil,
              drmData:FairPlayDrm? = nil
              ) -> AVPlayer? {
        guard let url = URL(string: path) else {
           return nil
        }
        self.initTime = initTime
        self.isAutoPlay = isAutoPlay
        self.drmData = drmData
        let player = createPlayer(url, buffer:buffer, header:header, assetInfo: assetInfo)
        return player
    }
    
    func playInit(duration:Double){
        if self.initTime > 0 && duration > 0 {
            let pct = self.initTime / duration
            if pct < Double(MetvNetwork.maxWatchedProgress) {
                seek(initTime)
            }
        }
        guard let currentPlayer = player else { return }
        if self.currentRate != 1 {
            DispatchQueue.main.async {
                currentPlayer.rate = self.currentRate
            }
        }
        if self.isAutoPlay { self.resume() }
        else { self.pause() }
        /*
        guard let currentItem = currentPlayer.currentItem else { return }
        
        currentItem.asset.allMediaSelections.forEach{ item in
            //DataLog.d("MediaSelection " + item.description, tag: self.tag)
        }
        currentItem.asset.availableMediaCharacteristicsWithMediaSelectionOptions.forEach{ item in// DataLog.d("MediaCharacteristics " + item.rawValue, tag: self.tag)
        }
        currentItem.asset.availableMetadataFormats.forEach{ item in
            //DataLog.d("MetadataFormat " + item.rawValue, tag: self.tag)
        }*/
    }
    
    func stop() {
        ComponentLog.d("on Stop", tag: self.tag)
        destory()
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
    
    // asset delegate
    func onFindAllInfo(_ info: AssetPlayerInfo) {
        self.delegate?.onPlayerAssetInfo(info)
    }
    
    func onAssetLoadError(_ error: PlayerError) {
        self.delegate?.onPlayerError(playerError: error)
    }
    
    func onAssetEvent(_ evt :AssetLoadEvent) {
        switch evt {
        case .ready:
            self.resume()
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
}


