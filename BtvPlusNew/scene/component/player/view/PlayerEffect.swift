//
//  PosterType01.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI
import Combine

struct PlayerEffect: PageView{
    @EnvironmentObject var pagePresenter:PagePresenter
    @ObservedObject var viewModel: BtvPlayerModel = BtvPlayerModel()
    
    @State var brightness:CGFloat? = nil
    @State var volume:Float? = nil
    @State var rate:Float? = nil
    @State var message:String? = nil
    
    @State var imgBrightness:String = Asset.player.brightnessLv0
    @State var imgVolume:String = Asset.player.volumeOn
    
    @State var textBrightness:String = "0"
    @State var textVolume:String =  "0"
    @State var textSeeking:String =  ""
    @State var textTime:String =  ""
    
    @State var showBrightness:Bool = false
    @State var showVolume:Bool = false
    @State var showSeeking:Bool = false
    @State var isFullScreen:Bool = false
    
    @State var textWillMoveTime:String = ""
    @State var showSeekForward:Bool = false
    @State var showSeekBackward:Bool = false
    
    var body: some View {
        ZStack(alignment: .bottom){
            ZStack{
                if self.showSeeking {
                    VStack(spacing:Dimen.margin.tiny){
                        Text(self.textSeeking)
                            .modifier(BoldTextStyle(
                                    size: Font.size.bold,
                                    color: Color.app.white)
                            )
                        Text(self.textTime)
                            .modifier(BoldTextStyle(
                                    size: Font.size.regular,
                                    color: Color.app.greyLight)
                            )
                    }
                }
                Spacer()
                    .modifier(MatchParent())
                    .background(Color.app.black)
                    .opacity(self.showSeeking ? 0.5 : 0)
            }
            HStack(spacing:0){
                ZStack{
                    if self.showBrightness {
                        VStack(spacing:Dimen.margin.thinExtra){
                            Image( self.imgBrightness )
                                .renderingMode(.original).resizable()
                                .scaledToFit()
                                .modifier(MatchHorizontal(height:Dimen.icon.regular))
                            Text(self.textBrightness)
                                .modifier(BoldTextStyle(
                                        size: Font.size.boldExtra,
                                        color: Color.app.greyLight)
                                )
                        }
                    }
                    if self.showSeekBackward {
                        VStack(spacing:Dimen.margin.thinExtra){
                            Image( Asset.player.seekBackward )
                                .renderingMode(.original).resizable()
                                .scaledToFit()
                                .modifier(MatchHorizontal(
                                            height: self.isFullScreen ? Dimen.icon.light : Dimen.icon.tiny))
                            Text(self.textWillMoveTime)
                                .modifier(BoldTextStyle(
                                        size: self.isFullScreen ? Font.size.lightExtra :Font.size.tinyExtra,
                                        color: Color.app.white)
                                )
                        }
                    }
                    Spacer()
                        .modifier(MatchParent())
                        .background(Color.app.white)
                        .opacity(self.showBrightness ? 0.2 : 0)
                }
                ZStack{
                    if self.showVolume {
                        VStack(spacing:Dimen.margin.thinExtra){
                            Image( self.imgVolume )
                                .renderingMode(.original).resizable()
                                .scaledToFit()
                                .modifier(MatchHorizontal(height:Dimen.icon.regular))
                            Text(self.textVolume)
                                .modifier(BoldTextStyle(
                                        size: Font.size.boldExtra,
                                        color: Color.app.greyLight)
                                )
                        }
                    }
                    if self.showSeekForward {
                        VStack(spacing:Dimen.margin.thinExtra){
                            Image( Asset.player.seekForward )
                                .renderingMode(.original).resizable()
                                .scaledToFit()
                                .modifier(MatchHorizontal(
                                            height: self.isFullScreen ? Dimen.icon.light : Dimen.icon.tiny))
                            Text(self.textWillMoveTime)
                                .modifier(BoldTextStyle(
                                        size: self.isFullScreen ? Font.size.lightExtra :Font.size.tinyExtra,
                                        color: Color.app.white)
                                )
                        }
                    }
                    Spacer()
                        .modifier(MatchParent())
                        .background(Color.app.white)
                        .opacity(self.showVolume ? 0.2 : 0)
                }
            }
            if self.message != nil {
                Text(self.message!)
                    .modifier(BoldTextStyle(
                                size: self.isFullScreen ? Font.size.bold : Font.size.regular,
                            color: Color.app.white)
                    )
                    .padding(.bottom,  self.isFullScreen ? PlayerUI.paddingFullScreen : PlayerUI.padding)
            }
        }
        .modifier(MatchParent())
        .onReceive(self.viewModel.$brightness){ brightness in
            if self.brightness == nil {
                self.brightness = brightness
                return
            }
            if self.brightness == brightness { return }
            self.brightness = brightness
            let value = min(brightness*100.0, 100)
            let lv = Int( ceil( value / 100 * 5 ) )
            self.imgBrightness = Asset.brightnessList[lv]
            self.textBrightness = Double(value).toInt().description
            self.delayBrightnessHidden()
        }
        .onReceive(self.viewModel.$volume){ volume in
            if self.volume == nil {
                self.volume = volume
                return
            }
            if self.volume == volume { return }
            self.volume = volume
            let value = min(volume*100.0, 100.0)
            let lv = Int( ceil( value / 100 * 3 ) )
            self.imgVolume = Asset.volumeList[lv]
            self.textVolume = Double(value).toInt().description
            self.delayVolumeHidden()
        }
        .onReceive(self.viewModel.$message){ message in
            guard let message = message else { return }
            if self.message == message { return }
            withAnimation{ self.message = message }
            self.delayMessageHidden()
        }
        .onReceive(self.viewModel.$rate){ rate in
            if self.rate == nil {
                self.rate = rate
                return
            }
            if self.rate == rate { return }
            withAnimation{ self.message = "x " + rate.description }
            self.delayMessageHidden()
        }
        .onReceive(self.viewModel.$streamEvent) { evt in
            guard let evt = evt else { return }
            switch evt {
            case .seeked: withAnimation{ self.showSeeking = false }
            default : do{}
            }
        }
        .onReceive(self.viewModel.$seeking){ seeking in
            if seeking == 0 {
                withAnimation{ self.showSeeking = false }
            }else{
                if !self.showSeeking {
                    withAnimation{ self.showSeeking = true }
                }
                let leading = seeking < 0 ? "- " : ""
                self.textSeeking = leading + abs(seeking).secToHourString()
            }
        }
        .onReceive(self.viewModel.$time) { tm in
            if !self.showSeeking { return }
            self.textTime = tm.secToHourString()
        }
        .onReceive(self.viewModel.$event) { evt in
            guard let evt = evt else { return }
            switch evt {
            case .seekForward(let t, _):
                self.textWillMoveTime = t.toInt().description + String.app.moveSec
                self.delaySeekForwardHidden()
            case .seekBackword(let t, _):
                self.textWillMoveTime = t.toInt().description + String.app.moveSec
                self.delaySeekBackwardHidden()
            default : do{}
            }
        }
        .onReceive(self.pagePresenter.$isFullScreen){fullScreen in
            self.isFullScreen = fullScreen
        }
            
    }//body
    
    
    @State var effectVolume:AnyCancellable?
    func delayVolumeHidden(){
        if !self.showVolume {
            withAnimation{ self.showVolume = true }
        }
        self.effectVolume?.cancel()
        self.effectVolume = Timer.publish(
            every: 1.5, on: .current, in: .common)
            .autoconnect()
            .sink() {_ in
                self.effectVolume?.cancel()
                withAnimation{ self.showVolume = false }
            }
    }
    
    @State var effectBrightness:AnyCancellable?
    func delayBrightnessHidden(){
        if !self.showBrightness {
            withAnimation{ self.showBrightness = true }
        }
        self.effectBrightness?.cancel()
        self.effectBrightness = Timer.publish(
            every: 1.5, on: .current, in: .common)
            .autoconnect()
            .sink() {_ in
                self.effectBrightness?.cancel()
                withAnimation{ self.showBrightness = false }
            }
    }
    
    @State var effectSeekForward:AnyCancellable?
    func delaySeekForwardHidden(){
        if !self.showSeekForward {
            withAnimation{ self.showSeekForward = true }
        }
        self.effectSeekForward?.cancel()
        self.effectSeekForward = Timer.publish(
            every: 1.5, on: .current, in: .common)
            .autoconnect()
            .sink() {_ in
                self.effectSeekForward?.cancel()
                withAnimation{ self.showSeekForward = false }
            }
    }
    
    @State var effectSeekBackward:AnyCancellable?
    func delaySeekBackwardHidden(){
        if !self.showSeekBackward {
            withAnimation{ self.showSeekBackward = true }
        }
        self.effectSeekBackward?.cancel()
        self.effectSeekBackward = Timer.publish(
            every: 1.5, on: .current, in: .common)
            .autoconnect()
            .sink() {_ in
                self.effectSeekBackward?.cancel()
                withAnimation{ self.showSeekBackward = false }
            }
    }
    
    @State var effectMessage:AnyCancellable?
    func delayMessageHidden(){
        self.effectMessage?.cancel()
        self.effectMessage = Timer.publish(
            every: 1.5, on: .current, in: .common)
            .autoconnect()
            .sink() {_ in
                self.effectMessage?.cancel()
                withAnimation{ self.message = nil }
            }
    }
    
}


#if DEBUG
struct PlayerEffect_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            PlayerEffect()
            .environmentObject(PagePresenter())
            .modifier(MatchParent())
        }
        .background(Color.brand.bg)
    }
}
#endif
