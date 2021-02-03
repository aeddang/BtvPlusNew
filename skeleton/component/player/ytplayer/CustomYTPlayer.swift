//
//  CustomYTPlayer.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/27.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import WebKit
import Combine
import UIKit

open class YTPlayerModel: ComponentObservable {
    var playerVars = [String: Any]()
    private(set) var useControl = true
    init(playerVars:[String: Any]? = nil) {
        if let vars = playerVars {
            self.playerVars = vars
        }else{
            self.playerVars["controls"] = 0
            self.playerVars["autoplay"] = 0
            self.playerVars["enablejsapi"] = 1
            self.playerVars["playsinline"] = 1
            self.playerVars["rel"] = 0
            self.playerVars["showinfo"] = 1
            self.playerVars["fs"] = 1
            self.playerVars["modestbranding"] = 1
            self.playerVars["disablekb"] = 1
        }
    }
    
    convenience init(useControl:Bool){
        self.init(playerVars:nil)
        self.setUseControl( useControl )
        self.useControl = useControl
    }
    
    func setUseControl(_ control:Bool) {
        if control {
            self.playerVars["controls"] = 1
            self.playerVars["enablejsapi"] = 0
        }else{
            self.playerVars["controls"] = 0
            self.playerVars["enablejsapi"] = 1
        }
    }
   
    func setAutoPlay(_ isAutoPlay:Bool) {
        if isAutoPlay {
            self.playerVars["autoplay"] = 1
        }else{
            self.playerVars["autoplay"] = 0
        }
    }
    
    func setInitTime(_ initTime:Double = 0.0 ) {
        if initTime <= 0.0 { return }
        self.playerVars["start"] = initTime
    }
}


struct CustomYTPlayer: UIViewRepresentable, PlayBack, YTPlayerViewDelegate {
    
    @ObservedObject var viewModel:PlayerModel
    @ObservedObject var ytPlayerModel:YTPlayerModel = YTPlayerModel()
    var playID:String?
    
    var playerVars = [String: Any]()
    
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        ComponentLog.d("playerViewDidBecomeReady", tag: self.tag)
        self.onLoaded()
    }
    
    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState){
        ComponentLog.i("YTPlayerState : " + state.rawValue, tag: self.tag)
        if self.viewModel.duration == 0.0 {
            playerView.getDuration(){ d in
                self.onDurationChange(Double(d))
            }
            ComponentLog.i("duration : " + self.viewModel.duration.description, tag: self.tag)
            
        }
        switch state {
        case .playing :self.onResumed()
        case .paused: self.onPaused()
        case .buffering: self.onBuffering()
        case .ended: self.onCompleted()
        default: break
        }
        
    }
    
    func playerView(_ playerView: YTPlayerView, didChangeTo quality: YTPlaybackQuality){
        ComponentLog.d("YTPlaybackQuality : " + quality.rawValue, tag: self.tag)
    }
    
    func playerView(_ playerView: YTPlayerView, receivedError error: YTPlayerError){
        ComponentLog.e("onError : " + error.rawValue, tag: self.tag)
        switch error {
        case .cannotFindVideo : self.onError(.playback("cannotFindVideo "+error.rawValue))
        case .videoNotFound: self.onError(.playback("videoNotFound "+error.rawValue))
        default: self.onError(.unknown(error.rawValue))
        }
    }
    
    func playerView(_ playerView: YTPlayerView, didPlayTime playTime: Float){
        self.onTimeChange(Double(playTime))
    }
    /*
    func playerViewPreferredInitialLoadingView(_ playerView: YTPlayerView) -> UIView? {
        return UIImageView(image:UIImage(contentsOfFile:Images.bgFloating))
    }*/
    
    func playerViewPreferredWebViewBackgroundColor(_ playerView: YTPlayerView) -> UIColor {
        return UIColor.black
    }



    func makeUIView(context: UIViewRepresentableContext<CustomYTPlayer>) -> YTPlayerView {
        let player = YTPlayerView(frame: .zero)
        player.delegate = self
        if let id = playID {
            player.load(videoId: id,playerVars:self.ytPlayerModel.playerVars)
            self.viewModel.path = id
        }
        return player
    }

    func updateUIView(_ uiView: YTPlayerView, context: UIViewRepresentableContext<CustomYTPlayer>) {
        if viewModel.status != .update { return }
        guard let evt = viewModel.event else { return }
        ComponentLog.d("updateUIView " + viewModel.status.rawValue , tag:self.tag)
        update(uiView, evt:evt)
        
    }
    
    private func update(_ player: YTPlayerView, evt:PlayerUIEvent){
        func onResume(){
            player.playVideo()
        }
        func onPause(){
            player.pauseVideo()
        }
        
        func onSeek(time:Double, play:Bool){
            player.seek(seekToSeconds: Float(time), allowSeekAhead: true)
            self.onSeek(time: time)
        }
        switch evt {
        case .load(let path, let isAutoPlay, let initTime, _):
            self.ytPlayerModel.setInitTime(initTime)
            self.ytPlayerModel.setAutoPlay(isAutoPlay)
            ComponentLog.d("load " + path + " " + isAutoPlay.description, tag:self.tag)
            player.load(videoId:path , playerVars:self.ytPlayerModel.playerVars)
            self.onLoad()
    
        case .togglePlay:
            if self.viewModel.isPlay {  onPause() } else { onResume() }
        case .resume: onResume()
        case .pause: onPause()
        case .stop: player.stopVideo()
        case .volume(_): break
        case .seekTime(let t, let play): onSeek(time:t, play: play)
        case .seekMove(let t, let play): onSeek(time:viewModel.time + t, play: play)
        case .seekProgress(let pct, let play):
            let t = viewModel.duration * Double(pct)
            onSeek(time:t, play: play)
        default: do{}
        }
        
        viewModel.event = nil
        
    }
}
#if DEBUG
struct ComponentYTPlayer_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            CPYTPlayer(viewModel:PlayerModel(), playID: "GgEFLb6QlbA").contentBody
                .frame(width: 250, height: 250, alignment: .center)
        }
    }
}
#endif
